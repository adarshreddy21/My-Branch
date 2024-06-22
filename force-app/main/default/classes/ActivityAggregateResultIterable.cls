global class ActivityAggregateResultIterable implements Iterable<AggregateResult> {
    public Boolean isEvent;  
    global ActivityAggregateResultIterable (Boolean isEvent){
        this.isEvent = isEvent;
    }
    global Iterator<AggregateResult> Iterator(){ 
	return new ActivityAggregateResultIterator(this.isEvent); 
} 

}