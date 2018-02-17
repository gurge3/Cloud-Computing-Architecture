package com.example.webapp.entity;

import javax.persistence.*;
import java.util.Objects;

@Entity
@Table(name = "user_photo", schema = "assignment2", catalog = "")
public class UserPhotoEntity {
    private int userPhotoId;
    private String photoPath;

    @OneToOne
    @JoinColumn(name="user_id")
    private UserEntity user;

    @Id
    @Column(name = "user_photo_id")
    public int getUserPhotoId() {
        return userPhotoId;
    }

    public void setUserPhotoId(int userPhotoId) {
        this.userPhotoId = userPhotoId;
    }

    @Basic
    @Column(name = "photo_path")
    public String getPhotoPath() {
        return photoPath;
    }

    public void setPhotoPath(String photoPath) {
        this.photoPath = photoPath;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserPhotoEntity that = (UserPhotoEntity) o;
        return userPhotoId == that.userPhotoId &&
                Objects.equals(photoPath, that.photoPath);
    }

    @Override
    public int hashCode() {

        return Objects.hash(userPhotoId, photoPath);
    }

    @OneToOne
    @JoinColumn(name="user_id")
    public UserEntity getUser() {
        return user;
    }

    public void setUser(UserEntity user) {
        this.user = user;
    }
}
