package com.example.webapp.entity;

import javax.persistence.*;
import java.util.Objects;

@Entity
@Table(name = "user_about_me", schema = "assignment2", catalog = "")
public class UserAboutMeEntity {
    private int id;
    private String aboutMe;
    private UserEntity user;

    @Id
    @Column(name = "id")
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    @Basic
    @Column(name = "about_me")
    public String getAboutMe() {
        return aboutMe;
    }

    public void setAboutMe(String aboutMe) {
        this.aboutMe = aboutMe;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserAboutMeEntity that = (UserAboutMeEntity) o;
        return id == that.id &&
                Objects.equals(aboutMe, that.aboutMe);
    }

    @Override
    public int hashCode() {

        return Objects.hash(id, aboutMe);
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
