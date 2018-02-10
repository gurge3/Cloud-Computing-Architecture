package com.example.webapp.service;

import com.example.webapp.config.PasswordConfiguration;
import com.example.webapp.dao.UserDao;
import com.example.webapp.entity.UserEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;

@Service
public class UserService {

    @Autowired
    private UserDao userDao;

    private PasswordEncoder encoder = PasswordConfiguration.passwordEncoder();

    @Transactional
    public boolean login(String email, String password) {
        UserEntity user = userDao.findUserByEmail(email);
        if (user == null) {
            return false;
        }
        if (encoder.matches(password, user.getUserPassword())) {
            return true;
        }
        return false;
    }

    @Transactional
    public boolean register(String email, String password) {
        UserEntity user = userDao.findUserByEmail(email);
        if (user == null) {
            UserEntity newUser = new UserEntity();
            newUser.setUserEmail(email);
            newUser.setUserPassword(encoder.encode(password));
            userDao.saveAndFlush(newUser);
            return true;
        }
        return false;
    }
}
