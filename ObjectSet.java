/*@
predicate listOf(Node node; list<Object> elems) =
  node == null ?
    elems == nil
  :
    node.value |-> ?v &*&
    node.next |-> ?n &*&
    listOf(n, ?nelems) &*&
    elems == cons(v, nelems);
    
predicate nodes(Node n0; int count) =
    n0 == null ?
        count == 0
    :
        n0.value |-> _ &*& n0.next |-> ?next &*&
        nodes(next, ?ncount) &*&
        count == 1 + ncount;    

predicate lseg(Node first, Node last; int size) =
	first == last ? size == 0 
		: first.value |-> _ &*& first.next |-> ?next &*&
		lseg(next, last, ?nsize) &*& size == nsize + 1;
		
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

fixpoint list<t> myTail<t>(list<t> xs) {
	switch (xs) {
	case nil: return nil;
	case cons(x, xs0): return xs0;
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

class ObjectSet {//implements Set{
	/*@
	predicate set(list<Object> elems) =
	head |-> ?h &*& listOf(h, elems) &*&
	size |-> length(elems) &*& distinctValues(elems) == true;
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
	//@ requires set(?elems) &*& containsInList(elems, e) == false;
	//@ ensures set(cons(e, elems)) &*& containsInList(cons(e, elems), e) == true;
	{
		//open set(elems);
		//if(this.isEmpty()) {
		//if(size == 0) {
			//@open set(elems);
			head = new Node(e, head);
			size++;
			//@close set(cons(e, elems));
		//} else {
		//	addAux(e,head);
		//}	
	}

	private void addAux (Object e, Node current)
	{
		//if(current.value != e) {			
			if (current.next == null) {
				current.next = new Node(e, null);
				size++;
			} else {
				addAux(e, current.next);
			}
		//}
	}
	
	public void removeFirst(Object e)
	//@ requires set(?elems) &*& elems != nil;
	//@ ensures set(tail(elems));
	{
		//@open set(elems);
		//@open listOf(head,elems);
		head = head.next;
		size--;
		//close listOf(head,tail(elems));
		//@close set(tail(elems));
	}

	public void remove(Object e)
	// requires set(?elems) &*& containsInList(elems, e) == true &*& elems != nil;
	// ensures set(removeFromList(elems,e));// &*& containsInList(removeFromList(elems,e), e) == false;
	{
		//@open set(elems);
		//@open listOf(head, elems);
		if(this.head.value == e) {
			head = head.next;
			size--;
			//@close set(removeFromList(elems,e));
			int heaf = 2;
		} else {		
			removeAuxTwo(e,head);
			// open listOf(head, ?elems1);
			size--;
			//close listOf(head, cons(head.value, elems));
			//@close set(removeFromList(elems,e));
		}
		
	}
	
	public void removeLoop(Object e)
	// requires set(?elems) &*& containsInList(elems, e) == true &*& elems != nil;
	// ensures set(removeFromList(elems,e));// &*& containsInList(removeFromList(elems,e), e) == false;
	{
		//@open set(elems);
		//@open listOf(head, elems);
		if(this.head.value == e) {
			head = head.next;
			size--;
			//@close set(removeFromList(elems,e));
			int heaf = 2;
		} else {
			
			Node prev = head;
			Node curr = head.next;
			
			//@close listOf(head, elems);	
			int ewtwet = 5;
			// open listOf(head.next, ?nelems);
			for (int i = 0; i < this.size; i++)
			//@invariant 0 <= i &*& i <= length(elems) &*& set(elems);
			{
				//@open listOf(head, _);
				int tgs = 3;
				prev = prev.next;
				tgs = 3;
				
			}
				//prev.next = prev.next.next;
				//size--;
		}
		
	}
	
	private void removeAuxTwo(Object e, Node previous)
	// requires listOf(previous, ?elems) &*& previous != null;
	// ensures listOf(previous, removeFromList(elems,e)) &*& length(elems) == 1 + length(removeFromList(elems,e));
	{
		//@ open listOf(previous, elems);
		Node current = previous.next;
		if (current != null) {
			//@ open listOf(current, ?elems1);
			if (current.value == e) {
				previous.next = current.next;
				//@ close listOf(previous, removeFromList(elems,e));
				// close listOf(current, elems);
				//size--;
				int afae = 2;
			} else {
				//@ close listOf(current, elems1);
				// close listOf(previous, elems);
				
				removeAuxTwo(e, current);
				//@ close listOf(previous, removeFromList(_,e));
				
							
				int afa = 2;
			}
		}	
	}

	private void removeAux(Object e, Node previous, Node current)
	// requires previous.value |-> ?v1 &*& previous.next |-> ?n1 &*& current.value |-> ?v2 &*& current.next |-> ?n2;
	// ensures previous.value |-> v1 &*& previous.next |-> n1 &*& current.value |-> v2 &*& current.next |-> n2;
	// requires listOf(previous, ?elems) &*& listOf(current, ?elems2);
	// ensures listOf(previous, elems) &*& containsInList(elems, e) == false;
	{
		if (current != null) {
			if (current.value == e) {
				previous.next = current.next;
				size--;
			} else {
				removeAux(e, current, current.next);
			}
		}		
	}


	public static void main(String[] args)
	// requires System_out(?o) &*& o != null;
	// ensures true;
	{
		ObjectSet set = new ObjectSet();
		Integer a = new Integer(1);
		Integer aa = new Integer(1);
		Integer b = new Integer(2);
		set.add(a);
		set.add(aa);
		set.add(b);
		System.out.println("size " + set.size);
		set.removeLoop(aa);
		System.out.println("size " + set.size);
		System.out.println(set.contains(a));
		System.out.println(set.contains(aa));
		System.out.println(set.contains(b));
		set.removeLoop(b);
		System.out.println("size " + set.size);
	}




}