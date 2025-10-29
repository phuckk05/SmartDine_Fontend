import 'dart:io';

class CorsProxyService {
  static const String _proxyPort = '8080';
  static const String _targetHost = 'smartdine-backend-oq2x.onrender.com';
  
  static Future<HttpServer> startProxy() async {
    final server = await HttpServer.bind('localhost', int.parse(_proxyPort));
    
    print('CORS Proxy server started on http://localhost:$_proxyPort');
    print('Proxying requests to https://$_targetHost');
    
    await for (HttpRequest request in server) {
      _handleRequest(request);
    }
    
    return server;
  }
  
  static void _handleRequest(HttpRequest request) async {
    final client = HttpClient();
    
    try {
      // Add CORS headers
      request.response.headers.add('Access-Control-Allow-Origin', '*');
      request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
      request.response.headers.add('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
      
      // Handle preflight requests
      if (request.method == 'OPTIONS') {
        request.response.statusCode = 200;
        await request.response.close();
        return;
      }
      
      // Create proxy request
      final uri = Uri.parse('https://$_targetHost${request.uri.path}${request.uri.hasQuery ? '?' + request.uri.query : ''}');
      final proxyRequest = await client.openUrl(request.method, uri);
      
      // Copy headers (except host)
      request.headers.forEach((name, values) {
        if (name.toLowerCase() != 'host') {
          proxyRequest.headers.set(name, values);
        }
      });
      
      // Copy body for POST/PUT requests
      if (request.method == 'POST' || request.method == 'PUT') {
        await request.forEach((data) {
          proxyRequest.add(data);
        });
      }
      
      final proxyResponse = await proxyRequest.close();
      
      // Copy response status and headers
      request.response.statusCode = proxyResponse.statusCode;
      proxyResponse.headers.forEach((name, values) {
        if (name.toLowerCase() != 'transfer-encoding') {
          request.response.headers.set(name, values);
        }
      });
      
      // Copy response body
      await proxyResponse.forEach((data) {
        request.response.add(data);
      });
      await request.response.close();
      
    } catch (e) {
      print('Proxy error: $e');
      request.response.statusCode = 500;
      request.response.write('Proxy error: $e');
      await request.response.close();
    } finally {
      client.close();
    }
  }
}