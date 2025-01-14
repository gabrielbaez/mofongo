# Mofongo

⚠️ **IMPORTANT DISCLAIMER** ⚠️

This application is **NOT** intended for production use. It is a playground project created to explore and demonstrate what Generative AI can do when tasked with creating code. The codebase was primarily generated using AI tools and serves as an experimental showcase of AI capabilities in software development.

## Purpose

This project exists to:
- Demonstrate AI's ability to generate functional code
- Explore the boundaries of AI-assisted development
- Serve as a learning resource for understanding AI's current capabilities and limitations in software development
- Provide examples of AI-generated tests, documentation, and architectural decisions

While the code may be functional, it has not undergone the rigorous security audits, performance optimizations, and thorough testing required for production applications.

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

## Default Admin Credentials

After setting up the application, you can log in with the following default admin credentials:

```
Username: admin
Password: welcome1
Email: admin@somewhereemail.com
```

⚠️ **Important**: For security reasons, please change these credentials immediately after your first login.

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
