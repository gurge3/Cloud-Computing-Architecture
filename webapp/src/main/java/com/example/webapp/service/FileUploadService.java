package com.example.webapp.service;

import com.example.webapp.dao.UserDao;
import com.example.webapp.dao.UserPhotoDao;
import com.example.webapp.entity.UserEntity;
import com.example.webapp.entity.UserPhotoEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.transaction.Transactional;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@Service
public class FileUploadService {
    private static String UPLOADED_FOLDER = "/home/gurge3/csye6225/dev/csye6225-git-demo/webapp/images/";

    @Autowired
    private UserPhotoDao userPhotoDao;

    @Autowired
    private UserDao userDao;

    public boolean saveUploadedFiles(List<MultipartFile> files, String username) throws IOException {
        UserEntity userEntity = userDao.findUserByEmail(username);
        System.out.println("username: " + username);
        if (userEntity == null) {
            return false;
        }
        for (MultipartFile file : files) {
            System.out.println(file.getOriginalFilename() + " There is files");
            if (file.isEmpty()) {
                System.out.println("Why is empty?");
                continue;
            }
            byte[] bytes = file.getBytes();
            String filePath =  UPLOADED_FOLDER + file.getOriginalFilename();
            System.out.println(filePath);
            Path path = Paths.get(filePath);
            try {
                Files.createDirectories(path.getParent());
                System.out.println("Path: " + path.toString());
                Files.write(path, bytes);
            } catch (IOException e) {
                e.printStackTrace();
            }
            System.out.println("Upload successfully!");
            UserPhotoEntity photo = new UserPhotoEntity();
            photo.setPhotoPath(filePath);
            photo.setUser(userEntity);

            userPhotoDao.saveAndFlush(photo);
        }
        return true;
    }

    @Transactional
    public boolean deletePhoto(String username) {
        for (UserPhotoEntity userPhotoEntity : userPhotoDao.findAll()) {
            if (userPhotoEntity.getUser().getUserEmail().equals(username)) {
                userPhotoDao.delete(userPhotoEntity);
                return true;
            }
        }
        return false;
    }

    @Transactional
    public String getPhotoPathByUsername(String username) {
        UserEntity userEntity = userDao.findUserByEmail(username);
        System.out.println("username: " + username);
        if (userEntity == null) {
            return null;
        }
        for (UserPhotoEntity userPhotoEntity : userPhotoDao.findAll()) {
            if (userPhotoEntity.getUser().getUserEmail().equals(username)) {
                return userPhotoEntity.getPhotoPath();
            }
        }
        return null;
    }
}
