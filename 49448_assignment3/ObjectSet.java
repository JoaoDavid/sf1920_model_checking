/*
 * Reliable Software
 * Department of Informatics
 * Faculty of Sciences
 * University of Lisbon
 * January 08, 2020
 * João David n49448
 */

/*@
predicate listOf(Node node; list<Object> elems) =
  node == null ?
    elems == nil
  :
    node.value |-> ?v &*&
    node.next |-> ?n &*&
    listOf(n, ?nelems) &*&
    elems == cons(v, nelems);  
		
fixpoint boolean containsInList<t>(list<t> xs, t value) {
	switch (xs) {
	case nil: return false;
	case cons(x, xs0): return (x == value ? true : containsInList(xs0, value));
	}
}

fixpoint list<t> removeFromList<t>(list<t> xs, t value) {
	switch (xs) {
	case nil: return nil;
	case cons(x, xs0): return (x == value ? xs0 : cons(x,removeFromList(xs0, value)));
	}
}

fixpoint boolean distinctValues<t>(list<t> xs) {
    switch (xs) {
        case nil: return true;
        case cons(x, xs0): return !containsInList(xs0,x) && distinctValues(xs0);
    }
}
@*/

class Node {	
	final Object value;
	Node next;
	
	Node (Object value, Node next)
	//@ requires true;
	//@ ensures this.value |-> value &*& this.next |-> next;
	{
		this.value = value;
		this.next = next;
	}
}

class ObjectSet {
	/*@
	predicate set(list<Object> elems) =
		head |-> ?h &*&
		listOf(h, elems) &*&
		size |-> length(elems) &*&
		distinctValues(elems) == true;
	@*/

	private Node head;
	private int size;

	private ObjectSet()
	//@ requires true;
    	//@ ensures set(nil);
	{
		head = null;
		size = 0;
	}

	public boolean isEmpty()
	//@ requires set(?elems);
   	//@ ensures set(elems) &*& result == (length(elems) == 0);
	{	
		return size == 0;
	}

	public int size()
	//@ requires set(?elems);
   	//@ ensures set(elems) &*& result == length(elems);
	{
		return size;
	}

	public void clear()
	//@ requires set(?elems);
	//@ ensures set(nil);
	{
		head = null;
		size = 0;
	}

	public boolean contains(Object e)
	//@ requires set(?elems);
	//@ ensures set(elems) &*& containsInList(elems, e) == result;
	{
		//@open set(elems);
		return contains(e, head);
		//@close set(elems);
	}

	private boolean contains (Object e, Node current)
	//@ requires listOf(current, ?elems);
	//@ ensures listOf(current, elems) &*& containsInList(elems, e) == result;
	{
		if (current == null) {
			//@open listOf(current, elems);
			return false;
			//@close listOf(current, nil);
		} else {
			//@open listOf(current, elems);
			return (current.value == e ? true : contains(e, current.next));
			//@close listOf(current, elems);
		}
	}

	public void add(Object e)
	//@ requires set(?elems) &*& containsInList(elems, e) == false &*& length(elems) < 2147483647;
	//@ ensures set(cons(e, elems)) &*& containsInList(cons(e, elems), e) == true;
	{
		//@open set(elems);
		head = new Node(e, head);
		size++;
		//@close set(cons(e, elems));	
	}

	public void remove(Object e)
	// requires set(?elems) &*& containsInList(elems, e) == true;
	// ensures set(removeFromList(elems,e)) &*& containsInList(removeFromList(elems,e), e) == false;
	{
		//@open set(elems);
		//@open listOf(head, elems);
		if(this.head.value == e) {
			head = head.next;
			size--;
			//@close set(removeFromList(elems,e));
		} else {		
			removeAux(e,head);			
			//close set(removeFromList(elems,e));
		}
	}	
	
	private void removeAux(Object e, Node previous)
	// requires listOf(previous, ?elems) &*& previous != null &*& containsInList(elems, e) == true ;
	// ensures listOf(previous, removeFromList(elems,e)) &*& distinctValues(removeFromList(elems,e)) == true;
	{
		//@ open listOf(previous, elems);
		Node current = previous.next;
		if (current != null) {
			//@ open listOf(current, ?elems1);
			if (current.value == e) {
				previous.next = current.next;
				size--;
				//@ close listOf(previous, removeFromList(elems,e));
			} else {				
				removeAux(e, current);
			}
		}	
	}
	
}