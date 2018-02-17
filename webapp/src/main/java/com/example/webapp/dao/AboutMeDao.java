package com.example.webapp.dao;

import com.example.webapp.entity.UserAboutMeEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AboutMeDao extends JpaRepository<UserAboutMeEntity, Integer> {
}
