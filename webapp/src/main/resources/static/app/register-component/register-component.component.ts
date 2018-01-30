import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { UserService } from 'app/service/user.service';
import { error } from 'util';

@Component({
  selector: 'app-register-component',
  templateUrl: './register-component.component.html',
  styleUrls: ['./register-component.component.css']
})
export class RegisterComponentComponent implements OnInit {

  model:any = {}
  isError: boolean = false;
  errorMessage: string;


  constructor(private router:Router, private userService: UserService) { }

  ngOnInit() {
  }

  register = () => {
    if (this.model.password1 !== this.model.password2) {
      this.isError = true;
      this.errorMessage = "password doesn't match";
      return;
    }
    this.userService.register(this.model.email, this.model.password1)
      .subscribe(
        response => {
        localStorage.setItem("user", response._body);
        this.router.navigate(["home"]);
      },
        error => {
          console.log("here");
          this.isError = true;
          this.errorMessage = error;
        });
  }

}
