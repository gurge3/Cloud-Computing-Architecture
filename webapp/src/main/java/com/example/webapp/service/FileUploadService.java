package com.example.webapp.service;

import com.amazonaws.AmazonServiceException;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.auth.profile.ProfileCredentialsProvider;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.example.webapp.dao.UserDao;
import com.example.webapp.dao.UserPhotoDao;
import com.example.webapp.entity.UserEntity;
import com.example.webapp.entity.UserPhotoEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.PropertySource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.transaction.Transactional;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@Service
public class FileUploadService {
    @Value("${resourceLocation}")
    private String uploadSource;

    @Value("${spring.http.multipart.location}")
    private String tempDir;

    private static String UPLOADED_FOLDER = "/home/gurge3/csye6225/dev/csye6225-git-demo/webapp/images/";

    @Autowired
    private UserPhotoDao userPhotoDao;

    @Autowired
    private UserDao userDao;

    public synchronized boolean saveUploadedFiles(MultipartFile file, String username) throws IOException {
        String currentStatus = uploadSource;
        System.out.println("Current uploading source: " + currentStatus);
        if ("s3".equals(currentStatus)) {
            System.out.println("Uploading File to s3");
            uploadFileToS3Bucket(file, username);
            return true;
        } else if ("local".equals(currentStatus)) {
            System.out.println("Uploading File to Local");
            uploadFilesToLocal(file, username);
            return true;
        } else {
            throw new IllegalArgumentException("Can't determine upload source!");
        }
    }

    public boolean uploadFilesToLocal(MultipartFile file, String username) throws IOException {
        UserEntity userEntity = userDao.findUserByEmail(username);
        System.out.println("username: " + username);
        if (userEntity == null) {
            return false;
        }

        System.out.println(file.getOriginalFilename() + " There is files");
        byte[] bytes = file.getBytes();
        String filePath = UPLOADED_FOLDER + file.getOriginalFilename();
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
        UserPhotoEntity photo = findPhotoByUserEmail(username);
        if (photo == null) {
            photo = new UserPhotoEntity();
        }
        photo.setPhotoPath("http://localhost:8000/" + filePath);
        photo.setUser(userEntity);
        userPhotoDao.saveAndFlush(photo);
        return true;
    }

    @Transactional
    public boolean uploadFileToS3Bucket(MultipartFile file, String username) {
        UserEntity userEntity = userDao.findUserByEmail(username);
        if (userEntity == null) {
            return false;
        }
        String bucketName = "s3.csye6225-spring2018-wux.tld";
        String accessKey = "AKIAJY6C3FIUKSIMAUCQ";
        String secretKey = "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";
        String uploadFileName = file.getOriginalFilename();
        try {
            BasicAWSCredentials credentials = new BasicAWSCredentials(accessKey, secretKey);
            AmazonS3 s3client = AmazonS3ClientBuilder.standard().withCredentials(new AWSStaticCredentialsProvider(credentials)).build();
            System.out.println("Created S3 Client.");
            s3client.putObject(new PutObjectRequest(bucketName, uploadFileName, convertMultipartFileToFile(file))
                    .withCannedAcl(CannedAccessControlList.PublicRead));
            System.out.println("uploading complete!");
            String url = "https://" + bucketName + ".s3.amazonaws.com/" + file.getOriginalFilename();
            System.out.println(url);
            UserPhotoEntity photo = findPhotoByUserEmail(username);
            if (photo == null) {
                photo = new UserPhotoEntity();
            }
            photo.setPhotoPath(url);
            photo.setUser(userEntity);
            userPhotoDao.saveAndFlush(photo);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private UserPhotoEntity findPhotoByUserEmail(String username) {
        List<UserPhotoEntity> photos = userPhotoDao.findAll();
        for (UserPhotoEntity photo : photos) {
            if (photo.getUser().getUserEmail().equals(username)) {
                return photo;
            }
        }
        return null;
    }

    private File convertMultipartFileToFile(MultipartFile file) throws IllegalStateException, IOException {
        System.out.println(tempDir + "/" + file.getOriginalFilename());
        File convertFile = new File(tempDir + "/" + file.getOriginalFilename());
        file.transferTo(convertFile);
        return convertFile;
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
