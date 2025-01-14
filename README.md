# Mofongo

A modern web application with a robust admin interface built with Ruby on Rails.

## Features

### Admin Interface
- Modern, responsive admin dashboard with a collapsible sidebar
- User management system with role-based access control
- Clean and intuitive navigation with Font Awesome icons
- Mobile-friendly design that works on all devices

## Technical Stack

* Ruby version: 3.2.2
* Rails version: 7.1.2
* Database: PostgreSQL
* Frontend: Bootstrap 5, Font Awesome 6
* Testing: Minitest

## Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/mofongo.git
cd mofongo
```

2. Install dependencies:
```bash
bundle install
yarn install
```

3. Setup database:
```bash
rails db:create db:migrate db:seed
```

4. Start the server:
```bash
docker compose up
```

## Development

### Running Tests
```bash
rails test:system  # Run system tests
rails test        # Run all tests
```

### Admin Interface Structure

The admin interface uses a modern sidebar design with the following features:

- Responsive sidebar that can be toggled on mobile devices
- User profile section with role display
- Dynamic navigation menu with submenu support
- Font Awesome icons for improved visual hierarchy
- Bootstrap-based layout for consistent styling

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
