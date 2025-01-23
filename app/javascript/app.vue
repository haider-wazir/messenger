<template>
  <div v-if="!currentUser" class="auth-container">
    <div class="auth-form">
      <h2>{{ isRegistering ? 'Register' : 'Login' }}</h2>
      <form @submit.prevent="isRegistering ? register() : login()">
        <div v-if="isRegistering" class="form-group">
          <input type="text" v-model="form.username" placeholder="Username" required>
        </div>
        <div class="form-group">
          <input type="email" v-model="form.email" placeholder="Email" required>
        </div>
        <div class="form-group">
          <input type="password" v-model="form.password" placeholder="Password" required>
        </div>
        <button type="submit">{{ isRegistering ? 'Register' : 'Login' }}</button>
      </form>
      <p class="toggle-auth" @click="isRegistering = !isRegistering">
        {{ isRegistering ? 'Already have an account? Login' : 'Need an account? Register' }}
      </p>
      <p v-if="error" class="error">{{ error }}</p>
    </div>
  </div>

  <div v-else class="messenger-container">
    <div class="sidebar">
      <div class="user-info">
        <span>{{ currentUser.username }}</span>
        <button @click="logout">Logout</button>
      </div>
      
      <div class="chat-list">
        <div class="chat-item" 
             @click="selectUser(null)"
             :class="{ 'active': selectedUser === null }">
          Group Chat
          <span v-if="unreadCounts['group'] > 0" class="unread-badge">
            {{ unreadCounts['group'] }}
          </span>
        </div>
        
        <div v-for="user in users" 
             :key="user.id" 
             class="chat-item"
             :class="{ 'active': selectedUser?.id === user.id }"
             @click="selectUser(user)">
          {{ user.username }}
          <span v-if="unreadCounts[user.id] > 0" class="unread-badge">
            {{ unreadCounts[user.id] }}
          </span>
        </div>
      </div>
    </div>

    <div class="chat-container">
      <div class="chat-header">
        <h2>{{ selectedUser ? selectedUser.username : 'Group Chat' }}</h2>
      </div>

      <div class="messages" ref="messagesContainer">
        <div v-for="message in messages" 
             :key="message.id" 
             class="message"
             :class="{ 'own-message': message.sender.id === currentUser.id }">
          <div class="message-content">
            <div class="message-header">
              <span class="sender">{{ message.sender.username }}</span>
              <span class="time">{{ new Date(message.created_at).toLocaleTimeString() }}</span>
            </div>
            <div class="message-text">{{ message.content }}</div>
          </div>
        </div>
      </div>

      <div class="message-input">
        <input type="text" 
               v-model="newMessage" 
               @keyup.enter="sendMessage"
               placeholder="Type a message...">
        <button @click="sendMessage">Send</button>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import { createConsumer } from '@rails/actioncable'
import jwtDecode from 'jwt-decode'

export default {
  data() {
    return {
      currentUser: null,
      users: [],
      selectedUser: null,
      messages: [],
      newMessage: '',
      messageSubscription: null,
      unreadSubscription: null,
      cable: null,
      unreadCounts: {},
      isRegistering: false,
      form: {
        email: '',
        password: '',
        username: ''
      },
      error: null
    }
  },

  mounted() {
    console.log('App mounted')
    const token = localStorage.getItem('token')
    if (token) {
      try {
        const decoded = jwtDecode(token)
        this.currentUser = {
          id: decoded.user_id,
          username: decoded.username
        }
        console.log('Current user:', this.currentUser)
        
        // Set default Authorization header for all requests
        axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
        
        this.loadUsers()
        this.loadMessages()
        this.loadUnreadCounts()
        this.setupCable()
      } catch (error) {
        console.error('Error initializing app:', error)
        this.logout()
      }
    } else {
      console.log('No token found')
    }
  },

  methods: {
    async login() {
      try {
        const response = await axios.post('/api/v1/auth/login', {
          email: this.form.email,
          password: this.form.password
        })
        
        localStorage.setItem('token', response.data.token)
        const decoded = jwtDecode(response.data.token)
        this.currentUser = {
          id: decoded.user_id,
          username: decoded.username
        }
        
        this.error = null
        await this.loadUsers()
        await this.loadUnreadCounts()
        this.setupUnreadSubscription()
        this.setupMessageSubscription()
      } catch (error) {
        console.error('Login error:', error)
        this.error = error.response?.data?.error || 'Login failed'
      }
    },

    async register() {
      try {
        const response = await axios.post('/api/v1/auth/register', {
          email: this.form.email,
          password: this.form.password,
          username: this.form.username
        })
        
        localStorage.setItem('token', response.data.token)
        const decoded = jwtDecode(response.data.token)
        this.currentUser = {
          id: decoded.user_id,
          username: decoded.username
        }
        
        this.error = null
        await this.loadUsers()
      } catch (error) {
        console.error('Registration error:', error)
        this.error = error.response?.data?.errors?.join(', ') || 'Registration failed'
      }
    },

    async loadUsers() {
      try {
        const response = await axios.get('/api/v1/users')
        this.users = response.data.filter(user => user.id !== this.currentUser.id)
      } catch (error) {
        console.error('Error loading users:', error)
      }
    },

    async loadMessages() {
      try {
        const endpoint = '/api/v1/messages'
        const params = this.selectedUser ? { user_id: this.selectedUser.id } : {}
        
        const response = await axios.get(endpoint, { params })
        this.messages = response.data
        
        this.$nextTick(() => {
          this.scrollToBottom()
        })
      } catch (error) {
        console.error('Error loading messages:', error)
      }
    },

    async loadUnreadCounts() {
      try {
        const response = await axios.get('/api/v1/messages/unread_counts')
        this.unreadCounts = response.data
      } catch (error) {
        console.error('Error loading unread counts:', error)
      }
    },

    async sendMessage() {
      if (!this.newMessage.trim()) return
      
      console.log('Sending message:', {
        content: this.newMessage,
        recipient_id: this.selectedUser?.id || null
      })
      
      try {
        const response = await axios.post('/api/v1/messages', {
          content: this.newMessage,
          recipient_id: this.selectedUser?.id || null
        }, {
          headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
        })
        console.log('Message sent successfully:', response.data)
        
        this.newMessage = ''
        // Don't add the message here since it will come through the WebSocket
      } catch (error) {
        console.error('Error sending message:', error.response || error)
      }
    },

    async markMessagesAsRead() {
      try {
        await axios.post('/api/v1/messages/mark_read', {
          user_id: this.selectedUser?.id
        })
      } catch (error) {
        console.error('Error marking messages as read:', error)
      }
    },

    async selectUser(user) {
      console.log('Selecting user:', user)
      this.selectedUser = user
      
      // Clear unread count immediately
      const key = user ? user.id.toString() : 'group'
      this.unreadCounts[key] = 0
      
      await this.loadMessages()
      await this.markMessagesAsRead()
      this.setupMessageSubscription()
    },

    scrollToBottom() {
      const container = this.$refs.messagesContainer
      if (container) {
        container.scrollTop = container.scrollHeight
      }
    },

    setupCable() {
      console.log('Setting up ActionCable...')
      const token = localStorage.getItem('token')
      
      if (!token) {
        console.error('No token found')
        return
      }
      
      try {
        // Check if token is expired
        const decodedToken = jwtDecode(token)
        if (decodedToken.exp * 1000 < Date.now()) {
          console.error('Token expired')
          this.logout()
          return
        }
        
        // Create consumer with token in URL for proper authentication
        if (this.cable) {
          this.cable.disconnect()
        }
        
        this.cable = createConsumer(`/cable?token=${token}`)
        console.log('ActionCable consumer created')
        
        this.setupMessageSubscription()
        this.setupUnreadSubscription()
      } catch (error) {
        console.error('Error setting up ActionCable:', error)
        this.logout()
      }
    },

    setupMessageSubscription() {
      if (this.messageSubscription) {
        this.messageSubscription.unsubscribe()
      }

      const channelName = this.selectedUser
        ? `messages_${[this.currentUser.id, this.selectedUser.id].sort().join('_')}`
        : 'messages_group'
      
      this.messageSubscription = this.cable.subscriptions.create(
        { 
          channel: 'MessagesChannel',
          room: channelName
        },
        {
          received: (data) => {
            // Add message to the list if it's not already there
            const messageExists = this.messages.some(m => m.id === data.id)
            if (!messageExists) {
              this.messages = [...this.messages, data]
              this.$nextTick(() => {
                this.scrollToBottom()
              })
              
              // Update unread counts for new messages not from current user
              if (data.sender.id !== this.currentUser.id) {
                const key = this.selectedUser ? this.selectedUser.id.toString() : 'group'
                const newCounts = { ...this.unreadCounts }
                newCounts[key] = (newCounts[key] || 0) + 1
                this.unreadCounts = newCounts
              }
            } else {
              console.log('Message already exists in list')
            }
          }
        }
      )
    },

    setupUnreadSubscription() {
      if (this.unreadSubscription) {
        this.unreadSubscription.unsubscribe()
      }

      this.unreadSubscription = this.cable.subscriptions.create(
        { channel: 'UnreadChannel' },
        {
          received: (data) => {
            console.log('Received unread counts:', data)
            
            // Update all unread counts
            const newCounts = { ...this.unreadCounts }
            Object.entries(data).forEach(([key, count]) => {
              if (count > 0) {
                newCounts[key] = count
              } else {
                delete newCounts[key]
              }
            })
            this.unreadCounts = newCounts
          }
        }
      )
    },

    logout() {
      localStorage.removeItem('token')
      this.currentUser = null
      this.users = []
      this.selectedUser = null
      this.messages = []
      this.unreadCounts = {}
      
      if (this.messageSubscription) {
        this.messageSubscription.unsubscribe()
        this.messageSubscription = null
      }
      
      if (this.unreadSubscription) {
        this.unreadSubscription.unsubscribe()
        this.unreadSubscription = null
      }
    }
  }
}
</script>

<style scoped>
.messenger-container {
  display: flex;
  height: 100vh;
  background-color: #f5f5f5;
}

.auth-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background-color: #f5f5f5;
}

.auth-form {
  background-color: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 400px;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group input {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.toggle-auth {
  margin-top: 1rem;
  color: #007bff;
  cursor: pointer;
}

.error {
  color: red;
  margin-top: 1rem;
}

.sidebar {
  width: 300px;
  background-color: white;
  border-right: 1px solid #ddd;
  display: flex;
  flex-direction: column;
}

.user-info {
  padding: 1rem;
  border-bottom: 1px solid #ddd;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chat-list {
  flex-grow: 1;
  overflow-y: auto;
}

.chat-item {
  padding: 1rem;
  cursor: pointer;
  border-bottom: 1px solid #ddd;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chat-item:hover {
  background-color: #f8f9fa;
}

.chat-item.active {
  background-color: #e9ecef;
}

.unread-badge {
  background-color: #007bff;
  color: white;
  border-radius: 50%;
  padding: 0.25rem 0.5rem;
  margin-left: 0.5rem;
  font-size: 0.8rem;
}

.chat-container {
  flex-grow: 1;
  display: flex;
  flex-direction: column;
}

.chat-header {
  padding: 1rem;
  background-color: white;
  border-bottom: 1px solid #ddd;
}

.messages {
  flex-grow: 1;
  padding: 1rem;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.message {
  margin-bottom: 1rem;
  max-width: 70%;
}

.message.own-message {
  align-self: flex-end;
}

.message-content {
  background-color: white;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.own-message .message-content {
  background-color: #007bff;
  color: white;
}

.message-header {
  margin-bottom: 0.25rem;
  font-size: 0.8rem;
}

.sender {
  font-weight: bold;
}

.time {
  margin-left: 0.5rem;
  color: #6c757d;
}

.own-message .time {
  color: #e9ecef;
}

.message-input {
  padding: 1rem;
  background-color: white;
  border-top: 1px solid #ddd;
  display: flex;
  gap: 1rem;
}

.message-input input {
  flex-grow: 1;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
}

button {
  padding: 0.5rem 1rem;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button:hover {
  background-color: #0056b3;
}
</style>
