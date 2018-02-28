import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';

import { AppComponent } from './app.component';
import { LoginComponentComponent } from './login-component/login-component.component';
import { RegisterComponentComponent } from './register-component/register-component.component';
import { MainComponentComponent } from './main-component/main-component.component';
import { AppRoutingModule } from './app-routing/app-routing.component';
import { UserService } from 'app/service/user.service';
import { AboutMeComponent } from './about-me/about-me.component';
import { AboutMeService } from './service/about-me.service';
import { ImageUploadModule } from "angular2-image-upload";
import { PhotoService } from './service/photo.service';

@NgModule({
  declarations: [
    AppComponent,
    LoginComponentComponent,
    RegisterComponentComponent,
    MainComponentComponent,
    AboutMeComponent
  ],
  imports: [
    AppRoutingModule,
    BrowserModule,
    FormsModule,
    HttpModule,
    ImageUploadModule.forRoot()
  ],
  providers: [UserService, AboutMeService, PhotoService],
  bootstrap: [AppComponent]
})
export class AppModule { }
