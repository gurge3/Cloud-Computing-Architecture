import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router/src/router';
import { AboutMeService } from '../service/about-me.service';
import { PhotoService } from '../service/photo.service';

@Component({
  selector: 'app-main-component',
  templateUrl: './main-component.component.html',
  styleUrls: ['./main-component.component.css']
})
export class MainComponentComponent implements OnInit {

  constructor(private router: Router, private aboutMeService: AboutMeService,
              private photoService: PhotoService) { }

  user: string;
  model: any = {};
  isError: boolean = false;
  isPhoto: boolean = false;
  filePath: String = "";
  errorMessage: String;

  date = new Date();

  ngOnInit() {
    this.user = localStorage.getItem("user");
    console.log(this.user);
    if (this.user === null) {
      this.router.navigate(["login"]);
    }
    this.photoService.getPhotoPathByUsername(this.user)
    .subscribe(
      (response) => {
        let path = response._body;
        if (path === "") {
          this.isPhoto = false; 
        } else {
          this.isPhoto = true;
          this.filePath = path;
        }
      }
    )
  }

  logOut = () => {
    localStorage.clear();
    this.router.navigate(["login"]);
  }

  deletePhoto = () => {
    this.photoService.deletePhotoByUsername(this.user)
      .subscribe(
        (response) => {
          alert(response);
          this.isPhoto = false;
        }, (error) => {
          this.isError = true;
          this.errorMessage = error;
        }
      )
  }
  submit = () => {
    this.aboutMeService.setAboutMeByUsername(this.user, this.model.aboutMe)
      .subscribe(
        (response) => {
          alert(response);
        },
        (error) => {
          this.isError = true;
          this.errorMessage = error;
        }
      )
  }
}
