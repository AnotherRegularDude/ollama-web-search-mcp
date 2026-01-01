# Ollama Web Search MCP Server

[![CI](https://github.com/AnotherRegularDude/ollama-web-search-mcp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/AnotherRegularDude/ollama-web-search-mcp/actions/workflows/ci.yml) [![Coverage Status](https://coveralls.io/repos/github/AnotherRegularDude/ollama-web-search-mcp/badge.svg?branch=main)](https://coveralls.io/github/AnotherRegularDude/ollama-web-search-mcp?branch=main)

A Model Context Protocol (MCP) server that provides web search and web fetch capabilities to AI assistants using the Ollama web search API. This server allows LLMs to access real-time information from the web through standardized MCP interfaces with sophisticated formatting capabilities.

## Quickstart: Run the MCP Server

The server needs Ruby 3.4.8, Bundler, and an `OLLAMA_API_KEY`.

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
        "max_results": 2,
        "truncate": true,
        "max_chars": 10000
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
        "url": "https://example.com",
        "truncate": true,
        "max_chars": 50000
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
  - [Layered Architecture](#layered-architecture)
  - [Service Layer](#service-layer)
  - [Adapter Layer](#adapter-layer)
  - [Data Layer](#data-layer)
  - [Formatter System](#formatter-system)
  - [MCP Layer](#mcp-layer)
- [Formatter System Details](#formatter-system-details)
  - [Component-Based Formatting](#component-based-formatting)
  - [Truncation System](#truncation-system)
  - [Node Structure](#node-structure)
- [Contributing](#contributing)
- [License](#license)
- [Additional Resources](#additional-resources)

## Overview

This Ruby-based MCP (Model Context Protocol) server implementation enables AI assistants to perform web searches and fetch web content using the Ollama web search API. The project follows the MCP specification to provide a standardized way for AI models to access external information with a sophisticated component-based formatting system.

The server exposes two primary tools:
1. `web_search` - Performs web searches with configurable result limits and content formatting
2. `web_fetch` - Retrieves content from specific URLs with advanced formatting capabilities

## Features

- **Web Search Functionality**:
  - Perform web searches through Ollama's web search API
  - Configurable maximum results (1-10)
  - Content truncation with configurable character limits
  - Structured search results with title, URL, and content

- **Web Fetch Functionality**:
  - Fetch web page content from specific URLs
  - Content truncation with configurable character limits
  - Related content links extraction
  - Metadata preservation

- **Advanced Formatting System**:
  - Component-based formatting pipeline
  - Content truncation with smart redistribution
  - Markdown output format
  - Configurable character limits
  - Consistent formatting across tools

- **Technical Features**:
  - Type-safe data structures using Dry::Struct
  - Service-oriented architecture
  - Comprehensive error handling
  - Support for both STDIO and HTTP transport protocols
  - Configurable MCP protocol versions

## Prerequisites

- Ruby 3.4.8
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

### Required Environment Variables
```bash
# API key for authenticating with the Ollama web search API
export OLLAMA_API_KEY="your-api-key-here"
```

### Optional Environment Variables
```bash
# MCP Protocol version (optional, defaults to "2025-06-18")
# Supported versions: "2025-06-18", "2025-03-26", "2024-11-05"
export MCP_PROTOCOL_VERSION="2025-03-26"
```

### Configuration Files
- `.ruby-version` - Specifies Ruby version (3.4.8)
- `Gemfile` - Ruby dependencies
- `config/application.rb` - Main application configuration

### Defaults
- Default maximum search results: 5
- Default HTTP server port: 8080
- Default content truncation: enabled (120,000 characters max)
- Default MCP protocol version: 2025-06-18

## API Reference

### Web Search Tool

**Tool Name**: `web_search`

**Description**: Performs a web search using Ollama's web search API and returns formatted results.

**Parameters**:
- `query` (string, required): The search query string
- `max_results` (integer, optional): Maximum results to return (1-10, default: 5)
- `truncate` (boolean, optional): Whether to truncate content (default: true)
- `max_chars` (integer, optional): Maximum characters to return (default: 120,000)

**Response Format**:
```
Search Results — "{query}"

### [Result Title 1](URL)
**URL:** URL
**Source:** search
**Content:**
---
Content snippet...
---

### [Result Title 2](URL)
**URL:** URL
**Source:** search
**Content:**
---
Content snippet...
---
```

**Example Request**:
```json
{
  "query": "latest AI news",
  "max_results": 3,
  "truncate": true,
  "max_chars": 50000
}
```

**Example Response** (truncated):
```markdown
Search Results — "latest AI news"

### [AI Breakthroughs in 2025](https://example.com/ai-2025)
**URL:** https://example.com/ai-2025
**Source:** search
**Content:**
---
Researchers have announced significant breakthroughs in neural network architectures...
---

### [New AI Legislation Proposed](https://example.com/ai-law)
**URL:** https://example.com/ai-law
**Source:** search
**Content:**
---
Governments around the world are considering new legislation to regulate AI development...
---
```

### Web Fetch Tool

**Tool Name**: `web_fetch`

**Description**: Fetches web page content from a specific URL using Ollama's web fetch API.

**Parameters**:
- `url` (string, required): The URL of the web page to fetch
- `truncate` (boolean, optional): Whether to truncate the content (default: true)
- `max_chars` (integer, optional): Maximum number of characters to return (default: 120,000)

**Response Format**:
```
**Source:** fetch
**URL:** URL

**Content:**
---
Page content...
---

**Links:**
- [Link 1](Link 1)
- [Link 2](Link 2)
```

**Example Request**:
```json
{
  "url": "https://example.com",
  "truncate": true,
  "max_chars": 30000
}
```

**Example Response** (truncated):
```markdown
**Source:** fetch
**URL:** https://example.com

**Content:**
---
This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission.

More information...

---
**Links:**
- [More information...](https://example.com/more)
```

## Development

### Project Structure

```
├── app/
│   ├── adapters/           # External service integrations
│   │   └── ollama_gateway.rb  # Ollama API communication
│   │
│   ├── cases/              # Business logic service objects
│   │   ├── formatter/      # Formatting system components
│   │   │   ├── base.rb         # Base formatter class
│   │   │   ├── search_results.rb # Search results formatter
│   │   │   └── fetch_result.rb   # Web fetch formatter
│   │   │
│   │   ├── node/           # Node processing services
│   │   │   ├── render_markdown.rb # Markdown rendering
│   │   │   ├── resolve_content.rb # Content resolution
│   │   │   └── truncate_content.rb # Content truncation
│   │   │
│   │   ├── search_web.rb   # Web search service
│   │   └── web_fetch.rb    # Web fetch service
│   │
│   ├── entities/           # Typed data structures
│   │   └── remote_content.rb # Remote content entity
│   │
│   ├── mcp_ext/            # MCP protocol implementation
│   │   ├── server_context.rb   # MCP server context
│   │   ├── server_factory.rb   # MCP server factory
│   │   ├── tool/           # MCP tool implementations
│   │   │   ├── base.rb         # Base tool class
│   │   │   ├── web_fetch.rb    # Web fetch tool
│   │   │   └── web_search.rb   # Web search tool
│   │   │
│   │   └── transport_handler/ # MCP transport handlers
│   │       ├── http.rb         # HTTP transport
│   │       ├── stdio.rb        # STDIO transport
│   │       └── base.rb         # Base transport handler
│   │
│   └── value/              # Value objects
│       ├── content_pointer.rb # Related content pointer
│       ├── node.rb            # Formatting node structure
│       └── root_node.rb       # Root node structure
│
├── bin/                    # Executable scripts
│   ├── http_server         # HTTP server entry point
│   └── mcp_server          # STDIO server entry point
│
├── config/                 # Application configuration
│   └── application.rb      # Main app configuration
│
├── lib/                    # Shared abstractions
│   ├── abstract_struct.rb  # Abstract struct base class
│   ├── service_object.rb   # Service object base class
│   └── types.rb            # Shared type definitions
│
├── spec/                   # Test files
│   ├── adapters/           # Adapter tests
│   ├── cases/              # Service object tests
│   ├── entities/           # Entity tests
│   ├── mcp_ext/            # MCP implementation tests
│   ├── config/             # Configuration tests
│   └── support/            # Test support files
│
└── tmp/                    # Temporary files
```

### Running Tests

Execute all tests using RSpec:

```bash
# Run all tests
rspec

# Run specific test files
rspec spec/cases/formatter/search_results_spec.rb
rspec spec/adapters/ollama_gateway_spec.rb

# Run tests with coverage report
COVER=true rspec
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

The project follows a layered service-oriented architecture with clear separation of concerns:

### Layered Architecture

| Layer | Responsibility | Key Components |
|-------|----------------|----------------|
| MCP Layer | MCP protocol implementation, tool interfaces | `MCPExt::Tool::WebSearch`, `MCPExt::Tool::WebFetch`, `MCPExt::ServerFactory` |
| Service Layer | Business logic, orchestration | `Cases::SearchWeb`, `Cases::WebFetch`, `Cases::Formatter::Base` |
| Formatter Layer | Content formatting and presentation | `Cases::Formatter::SearchResults`, `Cases::Formatter::FetchResult`, `Cases::Node::RenderMarkdown` |
| Adapter Layer | External API communication | `Adapters::OllamaGateway` |
| Data Layer | Type-safe data structures | `Entities::RemoteContent`, `Value::ContentPointer`, `Value::Node` |
| Value Layer | Simple value objects | `Value::ContentPointer`, `Value::Node`, `Value::RootNode` |

### Service Layer

Business logic is encapsulated in service objects under `app/cases/` that inherit from `ServiceObject`, a Resol-based base class providing consistent success/failure handling and Dry validation.

Key service objects:
- `Cases::SearchWeb` - Orchestrates web searches, interacting with the Ollama gateway and mapping results
- `Cases::WebFetch` - Orchestrates web content fetching, interacting with the Ollama gateway and mapping results
- `Cases::Formatter::Base` - Base class for all formatters with content truncation capabilities
- `Cases::Formatter::SearchResults` - Formats search results using the component-based system
- `Cases::Formatter::FetchResult` - Formats web fetch results using the component-based system

### Adapter Layer

External service integrations are encapsulated in adapters:
- `Adapters::OllamaGateway` - Handles all communication with the Ollama web search API
  - Performs web search requests
  - Performs web fetch requests
  - Handles authentication and error responses

### Data Layer

Entities are implemented using `Dry::Struct` for type-safe data structures:
- `Entities::RemoteContent` - Represents both search results and fetched content
  - Attributes: `title`, `url`, `content`, `related_content`, `source_type`
- `Value::ContentPointer` - Represents related content links
- `Value::Node` and `Value::RootNode` - Tree structures for formatting

### Formatter System

The project includes a sophisticated component-based formatter system that provides:
- **Component-based formatting** with reusable components
- **Content truncation** with smart redistribution
- **Markdown rendering** for human-readable output
- **Consistent formatting** across different output types

### MCP Layer

The MCP layer (`app/mcp_ext/`) contains:
- `MCPExt::Tool::WebSearch` - Implements the `web_search` MCP tool
  - Validates parameters
  - Calls the service layer
  - Formats results using the formatter system
- `MCPExt::Tool::WebFetch` - Implements the `web_fetch` MCP tool
  - Validates parameters
  - Calls the service layer
  - Formats results using the formatter system
- `MCPExt::ServerFactory` - Creates configured MCP servers
- `MCPExt::TransportHandler` - Routes transport configuration to appropriate handlers (STDIO or HTTP)

## Formatter System Details

### Component-Based Formatting

The formatter system uses a component-based approach to build structured output:

1. **Formatter Classes** (`Cases::Formatter::Base`, `Cases::Formatter::SearchResults`, `Cases::Formatter::FetchResult`)
   - Build a schema structure using `Value::Node` and `Value::RootNode` objects
   - Handle content truncation based on character limits
   - Process the schema through the rendering pipeline

2. **Node Processing** (`Cases::Node::RenderMarkdown`, `Cases::Node::ResolveContent`, `Cases::Node::TruncateContent`)
   - Render node structures to Markdown format
   - Resolve content text from nodes
   - Truncate content based on available character budget

3. **Node Types**
   - `:header` - Section headers
   - `:result` - Individual search result cards
   - `:metadata` - Source and URL information
   - `:content` - Main content blocks
   - `:links` - Lists of related links

### Truncation System

The truncation system provides intelligent content truncation:

1. **Truncation Process**:
   - Calculate formatting overhead (non-content characters)
   - Determine available content budget
   - Distribute budget equally among content sections
   - Redistribute unused budget to remaining sections

2. **Key Features**:
   - Smart redistribution of character budget
   - Equal distribution among content sections
   - Graceful handling of small token limits

3. **Implementation**:
   - `Cases::Node::TruncateContent` - Handles the truncation logic
   - Integrated into the formatter pipeline through `Cases::Formatter::Base`

### Node Structure

The formatter system uses a tree structure of nodes:

1. **RootNode** (`Value::RootNode`)
   - Contains metadata about the content
   - Has children nodes representing different sections

2. **Node** (`Value::Node`)
   - `type`: Symbol representing the node type (`:header`, `:result`, `:metadata`, `:content`, `:links`)
   - `data`: Hash containing node-specific data
   - `children`: Array of child nodes

3. **Example Structure for Search Results**:
   ```ruby
   Value::RootNode.new(
     metadata: { query: "ruby programming", total_results: 2 },
     children: [
       Value::Node.new(
         type: :header,
         data: { text: "Search Results — \"ruby programming\"" }
       ),
       Value::Node.new(
         type: :result,
         data: { title: "Ruby Programming", url: "https://ruby-lang.org", source: :search },
         children: [
           Value::Node.new(
             type: :content,
             data: { text: "Ruby is a dynamic programming language..." }
           )
         ]
       )
     ]
   )
   ```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for your changes
5. Run tests to ensure they pass
6. Update documentation as needed
7. Submit a pull request

### Development Guidelines

- **Code Style**: Follow existing Ruby style conventions as enforced by RuboCop
- **Type Safety**: Use `dry-rb` gems for type safety and validation
- **Service Objects**: Implement business logic in service objects under `app/cases/`
- **Formatter System**: Use the component-based formatter system for all output formatting
- **Testing**: Write comprehensive tests for all new functionality
- **Documentation**: Maintain consistent YARD documentation for classes and methods

### Testing JSON Structures

When testing HTTP requests and responses that involve JSON data, use these best practices:

1. **Use `be_json_as` for complete JSON structure matching**:
   ```ruby
   expect(request.body).to be_json_as(query: "test query", max_results: 5)
   ```

2. **Use `be_json_including` for partial JSON matching**:
   ```ruby
   expect(response.body).to be_json_including(status: "success")
   ```

3. **Use symbols as hash keys in test expectations** (the matchers handle symbol-to-string conversion):
   ```ruby
   expect(result.to_json).to be_json_as(
     title: "Example Page",
     url: "https://example.com",
     related_content: [
       {
         title: "Related Link",
         url: "https://example.com/related"
       }
       ]
   )
   ```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Additional Resources

- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [Ollama Web Search API Documentation](https://docs.ollama.com/capabilities/web-search)
- [Dry Struct Documentation](https://dry-rb.org/gems/dry-struct/)
- [Dry Types Documentation](https://dry-rb.org/gems/dry-types/)
- [Zeitwerk Documentation](https://github.com/fxn/zeitwerk)