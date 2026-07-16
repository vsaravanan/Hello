package com.saravanjs.hello.controller;

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


    @RequestMapping(value = "/init", method = {RequestMethod.GET, RequestMethod.POST})
    public ResponseEntity<String> init() {

        redisService.init();

        return ResponseEntity.ok("Inserted Product1...Product10");
    }

    @RequestMapping(value = "/buy/{user}", method = {RequestMethod.GET, RequestMethod.POST})
    public ResponseEntity<ProductRecord> buy(
            @PathVariable String user) {

        return ResponseEntity.ok(
                redisService.buy(user));
    }

    @RequestMapping(value = "/stock", method = {RequestMethod.GET, RequestMethod.POST})
    public ResponseEntity<Set<ProductRecord>> stock() {

        return ResponseEntity.ok(
                redisService.getStock());
    }


    @RequestMapping(value = "/cart/{user}", method = {RequestMethod.GET, RequestMethod.POST})
    public ResponseEntity<Set<ProductRecord>> cart(
            @PathVariable String user) {

        return ResponseEntity.ok(
                redisService.getCart(user));
    }
}