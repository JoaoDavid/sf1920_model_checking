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

fixpoint list<t> addAtTheEnd<t>(list<t> xs, t value) {
    switch (xs) {
        case nil: return cons(value,nil);
        case cons(x, xs0): return addAtTheEnd(xs0, value);
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
	head |-> ?h &*& listOf(h, elems) &*&
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
	//@ requires set(?elems) &*& containsInList(elems, e) == false;
	//@ ensures set(cons(e, elems)) &*& containsInList(cons(e, elems), e) == true;
	{
		//@open set(elems);
		head = new Node(e, head);
		size++;
		//@close set(cons(e, elems));	
	}

	public void remove(Object e)
	//@ requires set(?elems) &*& containsInList(elems, e) == true &*& elems != nil;
	//@ ensures set(removeFromList(elems,e)) &*& containsInList(removeFromList(elems,e), e) == false;
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
			//@close set(removeFromList(elems,e));
		}
	}	
	
	private void removeAuxTwo(Object e, Node previous)
	//@ requires listOf(previous, ?elems) &*& previous != null;
	//@ ensures listOf(previous, removeFromList(elems,e)) &*& length(elems) == 1 + length(removeFromList(elems,e));
	{
		//@ open listOf(previous, elems);
		Node current = previous.next;
		if (current != null) {
			//@ open listOf(current, ?elems1);
			if (current.value == e) {
				previous.next = current.next;
				//@ close listOf(previous, removeFromList(elems,e));
				size--;
			} else {				
				removeAuxTwo(e, current);
				//@ close listOf(previous, removeFromList(_,e));
			}
		}	
	}

	public static void main(String[] args)
	//@ requires System_out(?o) &*& o != null;
	//@ ensures true;
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