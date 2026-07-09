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

    @GetMapping("/hello")
    public ResponseEntity<Message> sayHello() {
        Message message = new Message("Testing hello");
        return ResponseEntity.ok(message);
    }
}