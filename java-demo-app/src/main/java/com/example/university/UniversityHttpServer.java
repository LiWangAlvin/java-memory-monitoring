package com.example.university;

import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

public class UniversityHttpServer {

    public static void main(String[] args) throws IOException {
        // 默认每次对象大小为 1024
        int objectSize = 1024;

        // 如果命令行参数中指定了对象大小，则使用该值
        if (args.length > 0) {
            objectSize = Integer.parseInt(args[0]);
        }

        int port = 8080;
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        server.createContext("/university", new UniversityHandler(objectSize));
        server.setExecutor(null); // creates a default executor
        server.start();
        System.out.println("Server started on port " + port);
    }

    static class UniversityHandler implements HttpHandler {
        private final int objectSize;

        public UniversityHandler(int objectSize) {
            this.objectSize = objectSize;
        }

        @Override
        public void handle(HttpExchange exchange) throws IOException {
            // Generate a new University object with specified size
            University university = new University("Example University", objectSize);

            // Create response
            String response = "Created a new university: " + university.getName() +
                              ", Data array size: " + university.getData().length + " integers";
            exchange.sendResponseHeaders(200, response.getBytes().length);
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes());
            os.close();

            // University object is eligible for GC after this method returns
        }
    }
}
