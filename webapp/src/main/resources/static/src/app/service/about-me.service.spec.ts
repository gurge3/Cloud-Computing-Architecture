/* tslint:disable:no-unused-variable */

import { TestBed, async, inject } from '@angular/core/testing';
import { AboutMeService } from './about-me.service';

describe('AboutMeService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [AboutMeService]
    });
  });

  it('should ...', inject([AboutMeService], (service: AboutMeService) => {
    expect(service).toBeTruthy();
  }));
});
