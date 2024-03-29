package com.example.webapp.controller.user;

import com.example.webapp.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

@RestController
@RequestMapping("/authenticate")
@CrossOrigin(origins="https://csye6225-spring2018-wux.me:4200", maxAge = 3600)
public class AuthenticationController {

    @Autowired
    private UserService userService;

    @RequestMapping(path = "/login", method = RequestMethod.POST)
    public ResponseEntity<?> login(@Valid @RequestBody UserModel userModel) {
        ResponseEntity<?> responseEntity = new ResponseEntity<>("Login Failed",
                HttpStatus.UNPROCESSABLE_ENTITY);
        if (userService.login(userModel.getEmail(), userModel.getPassword())) {
            responseEntity = new ResponseEntity<>(userModel.getEmail(), HttpStatus.OK);
        }
        return responseEntity;
    }

    @RequestMapping(path = "/register", method = RequestMethod.POST)
    public ResponseEntity<?> register(@Valid @RequestBody UserModel userModel) {
        ResponseEntity<?> responseEntity = new ResponseEntity<>("Register Failed",
                HttpStatus.UNPROCESSABLE_ENTITY);
        if (userService.register(userModel.getEmail(), userModel.getPassword())) {
            responseEntity = new ResponseEntity<>(userModel.getEmail(), HttpStatus.OK);
        }
        return responseEntity;
    }


}
