package com.example.webapp.controller.aboutMe;

import com.example.webapp.entity.UserAboutMeEntity;
import com.example.webapp.service.AboutMeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import javax.validation.constraints.NotNull;

@RestController
@RequestMapping("/aboutMe")
@CrossOrigin(origins="http://ec2-54-89-234-156.compute-1.amazonaws.com:4200", maxAge = 3600)
public class AboutMeController {
    @Autowired
    private AboutMeService aboutMeService;

    @GetMapping("/get/{username}/")
    public ResponseEntity<?> getAboutMeByUsername(@NotNull @PathVariable("username") String username) {
        ResponseEntity<?> response = new ResponseEntity<>("Can't find about me with this username!", HttpStatus.UNPROCESSABLE_ENTITY);
        UserAboutMeEntity userAboutMeEntity = aboutMeService.getAboutMeByUsername(username);
        if (userAboutMeEntity != null) {
            response = new ResponseEntity<>(userAboutMeEntity, HttpStatus.OK);
        }
        return response;
    }

    @PostMapping("/set")
    public ResponseEntity<?> setAboutMeByUsername(@Valid @RequestBody AboutMeModel aboutMeModel) {
        ResponseEntity<?> response = new ResponseEntity<>("Can't set about me with this username!", HttpStatus.UNPROCESSABLE_ENTITY);
        if (aboutMeService.setAboutMeByUsername(aboutMeModel)) {
            response = new ResponseEntity<>("About me has been successfully set", HttpStatus.OK);
        }
        return response;
    }
}
