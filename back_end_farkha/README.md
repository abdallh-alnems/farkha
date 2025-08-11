# Farkha API v2.0

A restructured and enhanced PHP API for poultry price management and suggestions system.

## 🚀 Features

- **Clean Architecture**: Organized with MVC pattern and separation of concerns
- **Secure Authentication**: JWT and Basic Auth support
- **Input Validation**: Comprehensive validation and sanitization
- **Error Handling**: Structured error responses and logging
- **CORS Support**: Configurable cross-origin resource sharing
- **Environment Configuration**: Secure configuration management
- **Repository Pattern**: Clean data access layer
- **Middleware System**: Flexible request processing
- **API Documentation**: Built-in documentation endpoint

## 📁 Project Structure

```
back_end_farkha/
├── app/
│   ├── config/          # Configuration files
│   │   ├── app.php      # Application settings
│   │   └── database.php # Database configuration
│   ├── controllers/     # API controllers
│   │   ├── AuthController.php
│   │   ├── PriceController.php
│   │   ├── SuggestionController.php
│   │   └── MainController.php
│   ├── core/           # Core framework files
│   │   ├── App.php     # Application bootstrap
│   │   ├── Database.php # Database connection
│   │   ├── BaseRepository.php # Base repository
│   │   └── Router.php  # URL routing
│   ├── middleware/     # Request middleware
│   │   ├── AuthMiddleware.php
│   │   └── CorsMiddleware.php
│   ├── models/         # Data repositories
│   │   ├── PriceRepository.php
│   │   ├── SuggestionRepository.php
│   │   └── MainRepository.php
│   └── utils/          # Utility classes
│       ├── ResponseHandler.php
│       ├── Validator.php
│       └── Logger.php
├── public/             # Web-accessible files
│   ├── index.php       # Entry point
│   ├── routes.php      # Route definitions
│   └── .htaccess       # Apache configuration
├── logs/               # Application logs
├── env.example         # Environment variables template
└── README.md          # This file
```

## ⚙️ Installation

1. **Clone or update the project**
2. **Set up environment variables**:
   ```bash
   cp env.example .env
   # Edit .env with your configuration
   ```
3. **Configure your web server** to point to the `public` directory
4. **Set up database** using the existing schema
5. **Set proper permissions**:
   ```bash
   chmod 755 logs/
   chmod 644 .env
   ```

## 🔧 Configuration

### Environment Variables (.env)

```env
# Application
APP_NAME="Farkha API"
APP_DEBUG=false
APP_TIMEZONE="Asia/Riyadh"

# Database
DB_HOST=localhost
DB_NAME=farkha
DB_USER=root
DB_PASS=your_password

# CORS
CORS_ALLOWED_ORIGINS=*

# Authentication
JWT_SECRET=your-very-secure-secret-key
BASIC_AUTH_USER=your_username
BASIC_AUTH_PASS=your_secure_password
```

## 📚 API Endpoints

### Authentication
- `POST /auth/login` - Login with Basic Auth
- `POST /auth/token` - Generate JWT token

### Prices
- `POST /prices/add` - Add new price (auth required)
- `GET /prices/latest?type={id}` - Get latest prices
- `GET /prices/feasibility-study` - Get feasibility study data
- `POST /prices/by-type` - Get prices by type
- `GET /prices/web` - Get web prices
- `GET /prices/stats?type={id}&days={days}` - Get statistics

### Suggestions
- `POST /suggestions/add` - Add new suggestion
- `GET /suggestions/recent?limit={limit}` - Get recent suggestions
- `GET /suggestions/search?q={keyword}` - Search suggestions
- `GET /suggestions/by-date?start={date}&end={date}` - Get by date range
- `GET /suggestions/stats` - Get statistics (auth required)

### Main Categories
- `GET /main` - Get all categories
- `GET /main/with-types` - Get categories with types
- `GET /main/{id}` - Get specific category
- `GET /main/{id}/with-types` - Get category with types
- `GET /main/stats` - Get statistics (auth required)

### Utility
- `GET /health` - Health check
- `GET /docs` - API documentation

## 🔒 Security Features

- **Input Validation**: All inputs are validated and sanitized
- **SQL Injection Protection**: Using prepared statements
- **XSS Protection**: HTML encoding of outputs
- **Authentication**: JWT and Basic Auth support
- **CORS Configuration**: Configurable origin restrictions
- **Environment Variables**: Sensitive data in .env files
- **Error Logging**: Secure error handling and logging

## 📊 Response Format

### Success Response
```json
{
  "status": "success",
  "message": "Operation completed successfully",
  "data": { ... },
  "timestamp": "2024-01-01 12:00:00"
}
```

### Error Response
```json
{
  "status": "error",
  "message": "Error description",
  "errors": { ... },
  "timestamp": "2024-01-01 12:00:00"
}
```

## 🛠️ Development

### Adding New Endpoints
1. Create controller method in appropriate controller
2. Add route in `public/routes.php`
3. Add validation if needed
4. Update documentation

### Database Access
Use the Repository pattern:
```php
$priceRepo = new PriceRepository();
$prices = $priceRepo->findAll();
```

### Adding Middleware
1. Create middleware class in `app/middleware/`
2. Implement `handle()` method
3. Add to route or globally in router

## 🔄 Migration from v1.0

The new API maintains backward compatibility with legacy endpoints:
- Old endpoints redirect to new ones (301 redirects)
- Same data structures where possible
- Enhanced error handling and validation

## 📝 Logging

Logs are stored in `logs/app.log` with the following levels:
- **INFO**: General information
- **WARNING**: Warning messages
- **ERROR**: Error messages
- **DEBUG**: Debug information

## 🚦 Testing

Test endpoints using curl or Postman:

```bash
# Health check
curl http://localhost/health

# Add price (with auth)
curl -X POST http://localhost/prices/add \
  -u username:password \
  -d "price=25.50&type_id=1"

# Get latest prices
curl http://localhost/prices/latest?type=1
```

## 📈 Performance Considerations

- Database connection pooling via singleton pattern
- Prepared statement caching
- Efficient query design with proper indexing
- Minimal memory footprint
- Fast routing with simple pattern matching

## 🤝 Contributing

1. Follow PSR-4 autoloading standards
2. Use meaningful variable and function names
3. Add proper documentation and comments
4. Validate all inputs
5. Handle errors gracefully
6. Write secure code

## 📞 Support

For issues or questions about the API, please check:
1. This documentation
2. Application logs in `logs/app.log`
3. Error responses for detailed messages

---

**Version**: 2.0  
**Last Updated**: 2024-01-01  
**Author**: Enhanced by AI Assistant
