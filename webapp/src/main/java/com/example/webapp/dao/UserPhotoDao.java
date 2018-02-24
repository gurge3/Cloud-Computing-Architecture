package com.example.webapp.dao;

import com.example.webapp.entity.UserPhotoEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface UserPhotoDao extends JpaRepository<UserPhotoEntity, Integer> {

}
