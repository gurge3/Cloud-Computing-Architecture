import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router/src/router';

@Component({
  selector: 'app-main-component',
  templateUrl: './main-component.component.html',
  styleUrls: ['./main-component.component.css']
})
export class MainComponentComponent implements OnInit {

  constructor(private router: Router) { }

  user: string;

  ngOnInit() {
    this.user = localStorage.getItem("user");
    console.log(this.user);
    if (this.user === null) {
      this.router.navigate(["login"]);
    }
  }

  logOut = () => {
    localStorage.clear();
    this.router.navigate(["login"]);
  }
}
