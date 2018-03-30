import { Injectable } from '@angular/core';
import { Http, Response } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import 'rxjs/Rx'

@Injectable()
export class AboutMeService {

  constructor(private http:Http) { }

  getAboutMeByUsername = (username: String): Observable<any> => {
    let url = "http://ec2-54-165-255-95.compute-1.amazonaws.com:8080/aboutMe/get/" + username + "/";
    return this.http.get(url)
      .map((response) => {
        return response;
      }, (error) => {
        return error;
      });
  }

  setAboutMeByUsername = (username: String, aboutMe: String): Observable<any> => {
    let url = "http://ec2-54-165-255-95.compute-1.amazonaws.com:8080/aboutMe/set";
    return this.http.post(url, {"username": username, "aboutMe": aboutMe})
      .map((response) => {
        return response;
      }, (error) => {
        return error;
      });
  }

}
