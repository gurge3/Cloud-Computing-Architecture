import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router/src/router';
import { UserService } from 'app/service/user.service';

@Component({
  selector: 'app-login-component',
  templateUrl: './login-component.component.html',
  styleUrls: ['./login-component.component.css']
})
export class LoginComponentComponent implements OnInit {

  model:any ={};
  isError: boolean = false;
  errorMessage: string;

  constructor(private router:Router, private userService: UserService) { }

  ngOnInit() {
  }

  login = () => {
    this.userService.login(this.model.username, this.model.password)
    .subscribe(
      (response) => {
        localStorage.setItem("user", response._body);
        this.router.navigate(["home"]);
      },
      (error) => {
        this.isError = true;
        this.errorMessage = "Invalid Credential";
      }
    )
  }

}
