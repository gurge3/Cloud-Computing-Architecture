package com.example.webapp.service;

import com.example.webapp.controller.aboutMe.AboutMeModel;
import com.example.webapp.dao.AboutMeDao;
import com.example.webapp.dao.UserDao;
import com.example.webapp.entity.UserAboutMeEntity;
import com.example.webapp.entity.UserEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.List;

@Service
public class AboutMeService {
    @Autowired
    private AboutMeDao aboutMeDao;

    @Autowired
    private UserDao userDao;

    @Transactional
    public UserAboutMeEntity getAboutMeByUsername(String username) {
        List<UserAboutMeEntity> aboutMeEntities = aboutMeDao.findAll();
        for (UserAboutMeEntity aboutMeEntity: aboutMeEntities) {
            System.out.println("Email entered: " + username
                    + " Searching: " + aboutMeEntity.getUser().getUserEmail());
            if (aboutMeEntity.getUser().getUserEmail().equals(username)) {
                System.out.println("Found!");
                return aboutMeEntity;
            }
        }
        return null;
    }

    @Transactional
    public boolean setAboutMeByUsername(AboutMeModel model) {
        UserAboutMeEntity aboutMe = new UserAboutMeEntity();
        aboutMe.setAboutMe(model.getAboutMe());
        UserEntity user = userDao.findUserByEmail(model.getUsername());
        if (user == null) {
            return false;
        }
        aboutMe.setUser(user);
        aboutMeDao.saveAndFlush(aboutMe);
        return true;
    }
}
