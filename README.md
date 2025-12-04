# Ollama Web Search MCP Server

[![CI](https://github.com/AnotherRegularDude/ollama-web-search-mcp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/AnotherRegularDude/ollama-web-search-mcp/actions/workflows/ci.yml) [![Coverage Status](https://coveralls.io/repos/github/AnotherRegularDude/ollama-web-search-mcp/badge.svg?branch=main)](https://coveralls.io/github/AnotherRegularDude/ollama-web-search-mcp?branch=main)

A Model Context Protocol (MCP) server that provides web search and web fetch capabilities to AI assistants using the Ollama web search API. This server allows LLMs to access real-time information from the web through standardized MCP interfaces.

## Quickstart: Run the MCP Server

The server needs Ruby 3.4.7, Bundler, and an `OLLAMA_API_KEY`.

1. Install dependencies:
   ```bash
   bundle install
   ```
2. Export the API key:
   ```bash
   export OLLAMA_API_KEY="your-api-key-here"
   ```

### STDIO transport

Local MCP clients can launch the STDIO server directly:

```bash
# Start via Ruby
bundle exec ruby bin/mcp_server

# Or via Rake
bundle exec rake start
```

### HTTP transport

Expose the MCP server over HTTP (defaults to port 8080):

```bash
bundle exec ruby bin/http_server           # port 8080
bundle exec ruby bin/http_server 3000      # custom port

# Or via Rake
bundle exec rake start_http                # port 8080
bundle exec rake "start_http[3000]"        # custom port
```

### Sample tool requests

With the HTTP server running, you can invoke the `web_search` and `web_fetch` tools over HTTP:

#### Web Search Tool
```bash
curl -s http://localhost:8080/ \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": "1",
    "method": "tools/call",
    "params": {
      "name": "web_search",
      "arguments": {
        "query": "latest AI news",
        "max_results": 2
      }
    }
  }'
```

#### Web Fetch Tool
```bash
curl -s http://localhost:8080/ \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": "1",
    "method": "tools/call",
    "params": {
      "name": "web_fetch",
      "arguments": {
        "url": "https://example.com"
      }
    }
  }'
```

The response contains formatted content inside `result.content[0].text`.

## Table of Contents

- [Quickstart: Run the MCP Server](#quickstart-run-the-mcp-server)
  - [STDIO transport](#stdio-transport)
  - [HTTP transport](#http-transport)
  - [Sample tool requests](#sample-tool-requests)
- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [API Reference](#api-reference)
  - [Web Search Tool](#web-search-tool)
  - [Web Fetch Tool](#web-fetch-tool)
- [Development](#development)
  - [Project Structure](#project-structure)
  - [Running Tests](#running-tests)
  - [Code Quality](#code-quality)
- [Architecture](#architecture)
  - [Service Layer](#service-layer)
  - [Adapter Layer](#adapter-layer)
  - [Data Layer](#data-layer)
  - [MCP Layer](#mcp-layer)
- [Contributing](#contributing)
- [License](#license)
- [Additional Resources](#additional-resources)

## Overview

This Ruby-based MCP server implementation enables AI assistants to perform web searches and fetch web content using the Ollama web search API. The project follows the MCP specification to provide a standardized way for AI models to access external information.

## Features

- Web search functionality through Ollama's web search API
- Web fetch functionality to retrieve content from specific URLs
- Standardized MCP interface for AI assistant integration
- Configurable result limits (1-10 results for search)
- Structured search results with title, URL, and content
- Web fetch results with title, content, and links
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
   git clone https://github.com/AnotherRegularDude/ollama-web-search-mcp.git
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

## API Reference

### Web Search Tool

The server exposes a tool for web search:

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

### Web Fetch Tool

The server also exposes a tool for fetching web content:

**Tool Name**: `web_fetch`

**Parameters**:
- `url` (string, required): The URL of the web page to fetch

**Response Format**:
```
Web page content from: {title}
URL: {first_link}

{content}
```

**Example Request**:
```json
{
  "url": "https://example.com"
}
```

## Development

### Project Structure

```
├── app/
│   ├── adapters/           # External service integrations (Ollama gateway)
│   ├── cases/              # Service objects implementing business logic
│   ├── entities/           # Typed data structures
│   └── mcp_ext/            # MCP tools, transports, and server factory
├── bin/                    # Executable scripts
├── config/                 # Application configuration and defaults
├── lib/                    # Shared abstractions (types, service base classes)
├── spec/                   # Test files
└── tmp/                    # Temporary files (cache, coverage artifacts)
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

Business logic lives in service objects under `app/cases/` that inherit from `ServiceObject`, a Resol-based base class that wraps Dry validation and consistent success/failure handling.

### Adapter Layer

External service integrations are encapsulated in adapters located in `app/adapters/`. The Ollama gateway handles API authentication and request/response processing.

### Data Layer

Entities are implemented using `Dry::Struct` for type-safe data structures. They provide immutable data objects with clear attribute definitions.

### MCP Layer

`app/mcp_ext/` contains the MCP server surface:
- `Tool::WebSearch` exposes the `web_search` MCP tool and formats responses.
- `Tool::WebFetch` exposes the `web_fetch` MCP tool and formats responses.
- `TransportHandler` builds STDIO or HTTP transports.
- `ServerFactory` wires the server with the selected transport and tools.

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
