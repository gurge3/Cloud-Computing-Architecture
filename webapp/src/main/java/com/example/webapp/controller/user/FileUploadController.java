package com.example.webapp.controller.user;

import com.example.webapp.service.FileUploadService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.xml.ws.Response;
import java.io.IOException;
import java.util.Arrays;

@Controller
@CrossOrigin(origins="http://ec2-35-172-139-134.compute-1.amazonaws.com:4200", maxAge = 3600)
public class FileUploadController {

    private final Logger logger = LoggerFactory.getLogger(FileUploadController.class);

    @Autowired
    private FileUploadService fileUploadService;

    @PostMapping("/photo/upload/{username}/")
    public ResponseEntity<?> uploadFile(@RequestParam("image") MultipartFile uploadFile,
                                        @PathVariable("username") String username) {
        logger.debug("Single file is uploading!");
        System.out.println("Uploading files");
        if (uploadFile.isEmpty()) {
            return new ResponseEntity<>("Please select a file!", HttpStatus.OK);
        }
        try {
            if (fileUploadService.saveUploadedFiles(uploadFile, username)) {
                return new ResponseEntity<>("File is successfully uploaded" + uploadFile.getOriginalFilename(),
                        new HttpHeaders(), HttpStatus.OK);
            }
        } catch (IOException ioe) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        return new ResponseEntity<>("File uploaded not successfully!", HttpStatus.UNPROCESSABLE_ENTITY);
    }

    @DeleteMapping("/photo/delete/{username}/")
    public ResponseEntity<?> deletePhotoByUsername(@PathVariable("username") String username) {
        ResponseEntity<String> response = new ResponseEntity<>("Delete is not success", HttpStatus.UNPROCESSABLE_ENTITY);
        if (fileUploadService.deletePhoto(username)) {
            response = new ResponseEntity<>("Delete successfully", HttpStatus.OK);
        }
        return response;
    }

    @GetMapping("/photo/get/{username}/")
    public ResponseEntity<?> getPhotoPathByUsername(@PathVariable("username") String username) {
        ResponseEntity<String> response  = new ResponseEntity<>("", HttpStatus.OK);
        String filePath = fileUploadService.getPhotoPathByUsername(username);
        if (filePath != null) {
            response = new ResponseEntity<>(filePath, HttpStatus.OK);
        }
        return response;
    }


}
