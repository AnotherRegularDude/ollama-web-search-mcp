# Ollama Web Search MCP Server

A Model Context Protocol (MCP) server that provides web search capabilities to AI assistants using the Ollama web search API. This server allows LLMs to access real-time information from the web through standardized MCP interfaces.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Running as STDIO Server](#running-as-stdio-server)
  - [Running as HTTP Server](#running-as-http-server)
- [API Reference](#api-reference)
  - [Web Search Tool](#web-search-tool)
- [Development](#development)
  - [Project Structure](#project-structure)
  - [Running Tests](#running-tests)
  - [Code Quality](#code-quality)
- [Architecture](#architecture)
  - [Service Layer](#service-layer)
  - [Adapter Layer](#adapter-layer)
  - [Data Layer](#data-layer)
- [Contributing](#contributing)
- [License](#license)

## Overview

This Ruby-based MCP server implementation enables AI assistants to perform web searches using the Ollama web search API. The project follows the MCP specification to provide a standardized way for AI models to access external information.

## Features

- Web search functionality through Ollama's web search API
- Standardized MCP interface for AI assistant integration
- Configurable result limits (1-10 results)
- Structured search results with title, URL, and content
- Support for both STDIO and HTTP transport protocols
- Type-safe data structures using Dry::Struct
- Comprehensive error handling

## Prerequisites

- Ruby 3.4.7
- Bundler gem
- Ollama API key

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/ollama-web-search-mcp.git
   cd ollama-web-search-mcp
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

## Configuration

The server requires an Ollama API key to function. Set the `OLLAMA_API_KEY` environment variable:

```bash
export OLLAMA_API_KEY="your-api-key-here"
```

## Usage

### Running as STDIO Server

To run the server using STDIO transport (suitable for direct integration with AI assistants):

```bash
ruby bin/mcp_server
```

Or using the Rake task:

```bash
rake start
```

### Running as HTTP Server

To run the server using HTTP transport:

```bash
# Default port 8080
ruby bin/http_server

# Custom port
ruby bin/http_server 3000
```

Or using the Rake task:

```bash
# Default port 8080
rake start_http

# Custom port
rake start_http[3000]
```

## API Reference

### Web Search Tool

The server exposes a single tool for web search:

**Tool Name**: `web_search`

**Parameters**:
- `query` (string, required): The search query string
- `max_results` (integer, optional): Maximum results to return (default 5, max 10)

**Response Format**:
```
Search results for: {query}

1. {title}
   URL: {url}
   Content: {content}

2. {title}
   URL: {url}
   Content: {content}
...
```

**Example Request**:
```json
{
  "query": "latest news about AI",
  "max_results": 3
}
```

## Development

### Project Structure

```
├── app/
│   ├── adapters/           # External service integrations (Ollama gateway)
│   ├── cases/              # Service objects implementing business logic
│   ├── entities/           # Data structures and entities
│   ├── interfaces/         # MCP server implementation
│   └── types.rb            # Type definitions
├── bin/                    # Executable scripts
├── config/                 # Application configuration
├── spec/                   # Test files
└── tmp/                    # Temporary files
```

### Running Tests

Execute all tests using RSpec:

```bash
# Run all tests
rspec

# Run specific test files
rspec spec/
```

### Code Quality

Run RuboCop for code style checking:

```bash
# Run RuboCop
rake rubocop

# Auto-correct RuboCop offenses
rake rubocop --auto-correct
```

## Architecture

The project follows a service-oriented architecture with clear separation of concerns:

### Service Layer

Business logic is encapsulated in service objects located in `app/cases/` that inherit from `Cases::Abstract`. This follows the Resol service pattern with parameter validation using Dry Types.

### Adapter Layer

External service integrations are encapsulated in adapters located in `app/adapters/`. The Ollama gateway handles API authentication and request/response processing.

### Data Layer

Entities are implemented using `Dry::Struct` for type-safe data structures. They provide immutable data objects with clear attribute definitions.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for your changes
5. Run tests to ensure they pass
6. Update documentation as needed
7. Submit a pull request

### Development Guidelines

- Follow existing code style and conventions
- Ensure type safety through Dry Types
- Validate parameter requirements and constraints
- Test error conditions and edge cases
- Maintain clear separation of concerns

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Additional Resources

- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [Ollama Web Search API Documentation](https://docs.ollama.com/capabilities/web-search)
- [Dry Struct Documentation](https://dry-rb.org/gems/dry-struct/)
- [Dry Types Documentation](https://dry-rb.org/gems/dry-types/)
