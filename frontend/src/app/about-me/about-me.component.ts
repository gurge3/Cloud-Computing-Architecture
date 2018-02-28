import { Component, OnInit } from '@angular/core';
import { AboutMeService } from '../service/about-me.service';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-about-me',
  templateUrl: './about-me.component.html',
  styleUrls: ['./about-me.component.css']
})
export class AboutMeComponent implements OnInit {

  constructor(private aboutMeService: AboutMeService, private route: ActivatedRoute) { }

  currentUser: String;
  aboutMe: String;
  sub: any;
  
  ngOnInit() {
    this.sub = this.route.params.subscribe(params => {
      this.currentUser = params['username'];
      this.aboutMeService.getAboutMeByUsername(this.currentUser)
        .subscribe(
          (response) => {
            let data = JSON.parse(response._body);
            this.aboutMe = data.aboutMe;  
          })
    })
  }

}
