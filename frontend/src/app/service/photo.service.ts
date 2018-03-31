import { Injectable } from '@angular/core';
import { Http, Response } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import 'rxjs/Rx'

@Injectable()
export class PhotoService {

  constructor(private http:Http) { }

  deletePhotoByUsername(username: String): Observable<any> {
    let url = "http://ec2-54-91-14-3.compute-1.amazonaws.com:8080/photo/delete/" + username + "/";
    return this.http.delete(url)
      .map(
        (response) => {
          return response;
        }, 
        (error) => {
          return error;
        }
      )
  }

  getPhotoPathByUsername(username: String): Observable<any> {
    let url = "http://ec2-54-91-14-3.compute-1.amazonaws.com:8080/photo/get/" + username + "/";
    return this.http.get(url)
      .map(
        (response) => {
          return response;
        }, 
        (error) => {
          return error;
        }
      )
  }

}
