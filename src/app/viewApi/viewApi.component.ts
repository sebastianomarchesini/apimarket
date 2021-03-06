import { Component, OnInit, OnDestroy} from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ApiPageService } from '../services/api-page.service';
import { ApiPage } from '../model/api';

@Component({
	selector: 'div [id="viewApi"]',
	templateUrl: './viewApi.component.html',
	styleUrls: ['./viewApi.component.css'],
})
export class ViewApiComponent implements OnInit, OnDestroy{
	private apiName:string; 
	private sub:any;
	api:ApiPage;
	constructor(private route: ActivatedRoute, private apiPageService:ApiPageService) { }
	ngOnInit(){
		this.sub=this.route.params.subscribe(params =>{
			this.apiName = params['name'];
		});
		
		this.apiPageService.getApi(this.apiName) 
        	.subscribe(result => { 
            	this.api = result; 
        }); 
		
	}
	ngOnDestroy(){
		this.sub.unsubscribe();	
	}
	getApi(){
		return this.api;	
	}
}
