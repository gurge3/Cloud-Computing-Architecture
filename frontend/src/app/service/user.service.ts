import { Injectable } from '@angular/core';
import { Http, Response } from '@angular/http';
import { Observable } from 'rxjs/Observable';

import 'rxjs/Rx'

@Injectable()
export class UserService {

  constructor(
    private http:Http
  ) { }

  login = (username: String, password: String): Observable<any> => {
    let url = "http://ec2-35-153-133-146.compute-1.amazonaws.com:8080/authenticate/login";
    return this.http.post(url, {"email": username, "password": password})
    .map((response)=> {
      return response;
    }, (error) => {
      return error;
    });
  }

  register = (username: String, password: String): Observable<any> => {
    let url = "http://ec2-35-153-133-146.compute-1.amazonaws.com:8080/authenticate/register";
    console.log(username + "   " + password);
    return this.http.post(url, {"email": username, "password": password})
    .map((response) => {
      console.log(response);
      return response;
    }).catch((err: Response) => {
      return Observable.throw("registered failed, duplicate user");
    })
  }
}
