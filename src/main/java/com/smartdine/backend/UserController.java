package com.smartdine.backend;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
public class UserController {

    @GetMapping("/hello")
    public String hello() {
        return "Hello World , I'm Phúc, I'm Doing demo spring-boot!";
    }
     @GetMapping("/test")
    public String test() {
        return "Done";
    }
}
