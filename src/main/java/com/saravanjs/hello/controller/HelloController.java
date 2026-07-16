package com.saravanjs.hello.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author Sarav on 06 Jul 2026
 * @project govtech
 * @package com.saravanjs.hello.controller
 * @class HelloController
 */

@RestController
@RequestMapping("/api")
public class HelloController {

    public record Message(String details) { }
    public record Db(String url, String username) { }

    @GetMapping("/hello")
    public ResponseEntity<Message> sayHello() {
        Message message = new Message("Testing db url user");
        return ResponseEntity.ok(message);
    }

    @GetMapping("/db")
    public ResponseEntity<Db> getDb() {

        String url = System.getenv("DATABASE_URL");
        String user = System.getenv("DATABASE_USER");

        System.out.println(url);
        System.out.println(user);

        Db db = new Db(url, user);
        return ResponseEntity.ok(db);
    }
}