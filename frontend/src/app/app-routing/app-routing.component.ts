import { NgModule } from '@angular/core';
import { Routes } from '@angular/router'
import { LoginComponentComponent } from 'app/login-component/login-component.component';
import { RegisterComponentComponent } from 'app/register-component/register-component.component';
import { MainComponentComponent } from 'app/main-component/main-component.component';
import { RouterModule } from '@angular/router/src/router_module';
import { CommonModule } from '@angular/common/src/common_module';
import { AboutMeComponent } from '../about-me/about-me.component';

const routes: Routes = [
  {path: 'login', component: LoginComponentComponent}, 
  {path: 'register', component: RegisterComponentComponent}, 
  {path: 'home', component: MainComponentComponent},
  {path: 'aboutMe/:username',component: AboutMeComponent },
  {path: '', redirectTo: 'login', pathMatch: 'full'}
]

@NgModule({
  imports: [
    RouterModule.forRoot(routes, {useHash: true}),
    CommonModule
  ],
  exports: [RouterModule]
})

export class AppRoutingModule {}