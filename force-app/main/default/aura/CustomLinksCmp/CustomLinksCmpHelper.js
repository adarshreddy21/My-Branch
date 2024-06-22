({
	handleLinkClick : function(component, event, helper) {
        let linkDetails = component.get('v.links');
        let selectedLinkName = event.target.dataset.name;
        let linkRec = linkDetails.filter((item)=>{
            return item.linkName == selectedLinkName;
        })[0];
        
        console.log(linkRec);
        
        if(!linkRec.target){
           window.open(linkRec.url); 
        }else if(linkRec.target == '_self'){
        	window.location.href = linkRec.url;
        }else if(linkRec.target == '_blank'){
        	window.open(linkRec.url, "name", "width=1358 height=758");    
        }
	}
})