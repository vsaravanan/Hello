package com.saravanjs.hello.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author Sarav on 06 Jul 2026
 * @project govtech
 * @package com.saravanjs.hello.controller
 * @class HelloController
 */

@RestController
public class HelloController {
    @GetMapping("/hello")
    public String sayHello() {
        return "Hello, World!";
    }
}