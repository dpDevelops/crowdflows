NodeHeap = function() constructor
{
	currentItemCount = 0;
	maxHeapSize = GRID_WIDTH*GRID_HEIGHT;
	items = array_create(maxHeapSize, -1);

	static Initialize = function(){
		items = array_create(maxHeapSize, -1)
		currentItemCount = 0;
	}
	static Add = function(_item){
		_item.HeapIndex = currentItemCount;
		items[currentItemCount] = _item;
		SortUp(_item);
		currentItemCount++;
		/*
			item.HeapIndex = currentItemCount;
			items[curentItemCount] = item;
			SortUp(item);
			currentItemCount++;
		*/
	}
	static RemoveFirst = function(){
		var _firstItem = items[0];
		currentItemCount--;
		items[0] = items[currentItemCount];
		items[0].HeapIndex = 0;
		SortDown(items[0]);
		return _firstItem;
		/*
			T firstItem = items[0];
			currentItemCount--;
			items[0] = items[currentItemCount];
			items[0].HeapIndex = 0;
			SortDown(items[0]);
			return firstItem;
		*/
	}
	static UpdateItem = function(_item){
		SortUp(_item);
		/*
			SortUp(item);
		*/
	}
	static Count = function(){
		return currentItemCount;
		/*
			return currentItemCount;
		*/
	}
	static Contains = function(_item){
		return array_equals(items[_item.HeapIndex].cell, _item.cell);
		/*
			return Equals(items[item.HeapIndex], item);
		*/
	}
	static SortUp = function(_item){
		var _parentIndex = (_item.HeapIndex-1)/2;
		while(true)
		{
			var _parentItem = items[_parentIndex];
			if(_item.CompareTo(_parentItem) > 0)
			{
				Swap(_item,_parentItem);
			} else {
				break;
			}
			_parentIndex = (_item.HeapIndex-1)/2;
			return _parentIndex;
		}
		/*
			int parentIndex = (item.HeapIndex-1)/2
			
			while(true)
			{
				T parentItem = items[parentIndex];
				if(item.compareTo(parentItem) > 0)
				{
					swap(item,parentItem);
				} else {
					break;
				}
				parentIndex = (item.HeapIndex-1)/2;
			}
		*/
	}
	static SortDown = function(_item){
		while(true)
		{
			var _childIndexLeft = _item.HeapIndex*2 + 1; 
			var _childIndexRight = _item.HeapIndex*2 + 2;
			var _swapIndex = 0;
			
			if(_childIndexLeft < currentItemCount)
			{
				_swapIndex = _childIndexLeft;
				
				if(_childIndexRight < currentItemCount)
				{
					if(items[_childIndexLeft].CompareTo(items[_childIndexRight]) < 0)
					{
						_swapIndex = _childIndexRight;
					}
				}
				if(_item.CompareTo(items[_swapIndex]) < 0)
				{
					Swap(_item, items[_swapIndex]);
				} else {
					return;
				}
			} else {
				return;
			}
		}
		/*
			while(true)
			{
				int childIndexLeft = item.HeapIndex*2 + 1;
				int childIndexRight = item.HeapIndex*2 + 2;
				int swapIndex = 0;
				
				if(childIndexLeft < currentItemCount)
				{
					swapIndex = childIndexLeft;
					
					if(childIndexRight < currentItemCount)
					{
						if(items[childIndexLeft].compareTo(items[childIndexRight]) < 0)
						{
							swapIndex = childIndexRight;
						}
					}
					if(item.compareTo(items[swapIndex]) < 0)
					{
						swap (item, items[swapIndex]);
					} else {
						return;
					}
				} else {
					return;
				}
			}
		*/
	}
	static Swap = function(itemA,itemB){
		items[itemA.HeapIndex] = itemB;
		items[itemB.HeapIndex] = itemA;
		var _itemAIndex = itemA.HeapIndex;
		itemA.HeapIndex = itemB.HeapIndex;
		itemB.HeapIndex = _itemAIndex;
		/*
			items[itemA.HeapIndex] = itemB;
			items[itemB.HeapIndex] = itemA;
			int itemAIndex = itemA.HeapIndex;
			itemA.HeapIndex = itemB.HeapIndex;
			itemB.HeapIndex = itemAIndex;
		*/
	}
}