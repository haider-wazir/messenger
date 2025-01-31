# Messenger App

A real-time messaging application built with Ruby on Rails and Vue.js.

## Features

- User authentication (register, login, logout)
- Real-time private and group messaging
- Real-time unread message notifications
- Message history
- User presence indicators
- Delete sent messages

## Prerequisites

- Ruby 3.3.1
- PostgreSQL
- Redis (for ActionCable)
- Node.js & npm
- Yarn

## System Dependencies (Ubuntu)

1. Update package list:
```bash
sudo apt-get update
```

2. Install Ruby dependencies:
```bash
sudo apt-get install -y build-essential libssl-dev libreadline-dev zlib1g-dev
```

3. Install PostgreSQL:
```bash
sudo apt-get install -y postgresql postgresql-contrib libpq-dev
```

4. Install Redis:
```bash
sudo apt-get install -y redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

5. Install Node.js and npm:
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

6. Install Yarn:
```bash
npm install -g yarn
```

## Setup

1. Clone the repository:
```bash
git clone [your-repo-url]
cd messenger
```

2. Install Ruby dependencies:
```bash
bundle install
```

3. Install JavaScript dependencies:
```bash
yarn install
```

4. Configure PostgreSQL:
```bash
sudo -u postgres createuser -s $USER
sudo -u postgres createdb messenger_development
sudo -u postgres createdb messenger_test
```

5. Setup database:
```bash
rails db:create
rails db:migrate
```

6. Create master.key and credentials:
```bash
EDITOR="vim" rails credentials:edit
```
Add the following structure (replace with your own values):
```yaml
secret_key_base: your_secret_key_base
jwt_secret: your_jwt_secret
```

7. Start the development server:
```bash
./bin/dev
```

8. Visit http://localhost:3000 in your browser

## Environment Variables

Create a `.env` file in the root directory with the following variables:
```bash
REDIS_URL=redis://localhost:6379/1
DATABASE_URL=postgresql://localhost/messenger_development
RAILS_ENV=development
```

## API Endpoints

### Authentication
- POST /api/v1/register - Register a new user
- POST /api/v1/login - Login user
- DELETE /api/v1/logout - Logout user

### Messages
- GET /api/v1/messages - Get all messages
- POST /api/v1/messages - Create a new message
- DELETE /api/v1/messages/:id - Delete a message

### Users
- GET /api/v1/users - Get all users

## Production Deployment

1. Additional production requirements:
   - Nginx
   - Systemd (for process management)
   - SSL certificate (recommended)

2. Install production dependencies:
```bash
sudo apt-get install -y nginx
```

3. Configure Nginx:
```bash
sudo nano /etc/nginx/sites-available/messenger
```
Add the following configuration:
```nginx
upstream messenger {
  server unix:///var/www/messenger/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name your-domain.com;
  root /var/www/messenger/public;

  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  location ^~ /cable {
    proxy_pass http://messenger;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
  }

  location / {
    proxy_pass http://messenger;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
  }
}
```

4. Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/messenger /etc/nginx/sites-enabled/messenger
sudo systemctl restart nginx
```

5. Setup production database:
```bash
RAILS_ENV=production rails db:create
RAILS_ENV=production rails db:migrate
```

6. Compile assets:
```bash
RAILS_ENV=production rails assets:precompile
```

7. Setup systemd service for Puma:
```bash
sudo nano /etc/systemd/system/puma.service
```
Add:
```ini
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=your-user
WorkingDirectory=/var/www/messenger
Environment=RAILS_ENV=production
ExecStart=/usr/local/bin/bundle exec puma -C config/puma.rb
Restart=always

[Install]
WantedBy=multi-user.target
```

8. Start the service:
```bash
sudo systemctl enable puma
sudo systemctl start puma
```

## Heroku Deployment

### Prerequisites

1. [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)
2. A Heroku account
3. Git installed

### Setup Steps

1. Create a new Heroku app:
```bash
heroku create your-app-name
```

2. Add PostgreSQL addon:
```bash
heroku addons:create heroku-postgresql:mini
```

3. Add Redis addon:
```bash
heroku addons:create heroku-redis:mini
```

4. Configure buildpacks:
```bash
heroku buildpacks:add heroku/nodejs
heroku buildpacks:add heroku/ruby
```

5. Set environment variables:
```bash
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
heroku config:set RACK_ENV=production
heroku config:set RAILS_ENV=production
```

6. Deploy the application:
```bash
git push heroku main
```

7. Run database migrations:
```bash
heroku run rails db:migrate
```

### Redis Configuration Notes

The app uses Redis for Action Cable (real-time features). On Heroku:
- Redis connections require TLS
- The app is configured to use Heroku's SSL termination
- No additional SSL configuration is needed as it's handled at Heroku's router level

### Common Heroku Issues

1. Redis Connection Errors:
   - Ensure you're using the latest Redis gem (>= 5.0)
   - Check if your Redis instance is provisioned: `heroku addons:info redis`
   - Verify Redis is running: `heroku ps`

2. Real-time Features Not Working:
   - Check if web dynos are running: `heroku ps`
   - Review logs for connection issues: `heroku logs --tail`
   - Ensure Redis configuration is correct in `config/cable.yml`

3. Database Issues:
   - Run migrations: `heroku run rails db:migrate`
   - Check database status: `heroku pg:info`

## Troubleshooting

1. If ActionCable (real-time features) is not working:
   - Ensure Redis is running: `sudo systemctl status redis-server`
   - Check Redis connection: `redis-cli ping` should return "PONG"
   - Check WebSocket connection in browser dev tools

2. If database connection fails:
   - Ensure PostgreSQL is running: `sudo systemctl status postgresql`
   - Check database.yml configuration
   - Verify database user permissions

3. Common issues:
   - Port 3000 already in use: `kill -9 $(lsof -i:3000 -t)`
   - Missing node modules: Run `yarn install`
   - Asset compilation errors: Run `rails assets:clobber` then `rails assets:precompile`

## License

MIT
