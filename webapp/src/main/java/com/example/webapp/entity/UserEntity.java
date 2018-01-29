package com.example.webapp.entity;

import javax.persistence.*;
import java.util.Objects;

@Entity
@Table(name = "user", schema = "assignment2", catalog = "")
public class UserEntity {
    private int userId;
    private String userEmail;
    private String userPassword;

    @Id
    @Column(name = "user_id")
    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    @Basic
    @Column(name = "user_email")
    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    @Basic
    @Column(name = "user_password")
    public String getUserPassword() {
        return userPassword;
    }

    public void setUserPassword(String userPassword) {
        this.userPassword = userPassword;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserEntity that = (UserEntity) o;
        return userId == that.userId &&
                Objects.equals(userEmail, that.userEmail) &&
                Objects.equals(userPassword, that.userPassword);
    }

    @Override
    public int hashCode() {

        return Objects.hash(userId, userEmail, userPassword);
    }
}
