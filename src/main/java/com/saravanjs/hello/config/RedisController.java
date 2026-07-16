package com.saravanjs.hello.config;

/**
 * @author Sarav on 16 Jul 2026
 * @project govtech
 * @package com.saravanjs.hello.controller
 * @class RedisController
 */

import com.saravanjs.hello.model.ProductRecord;
import com.saravanjs.hello.service.RedisService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Set;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/redis")
public class RedisController {

    private final RedisService redisService;


    @GetMapping("/init")
    public ResponseEntity<String> init() {

        redisService.init();

        return ResponseEntity.ok("Inserted Product1...Product10");
    }

    @PostMapping("/buy/{user}")
    public ResponseEntity<ProductRecord> buy(
            @PathVariable String user) {

        return ResponseEntity.ok(
                redisService.buy(user));
    }

    @GetMapping("/stock")
    public ResponseEntity<Set<ProductRecord>> stock() {

        return ResponseEntity.ok(
                redisService.getStock());
    }

    @GetMapping("/cart/{user}")
    public ResponseEntity<Set<ProductRecord>> cart(
            @PathVariable String user) {

        return ResponseEntity.ok(
                redisService.getCart(user));
    }
}