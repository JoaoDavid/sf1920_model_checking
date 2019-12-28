/*@
fixpoint boolean containsInList<t>(list<t> xs, t value) {
	switch (xs) {
	case nil: return false;
	case cons(x, xs0): return (x == value ? true : containsInList(xs0, value));
	}
}

fixpoint list<t> removeFromList<t>(list<t> xs, t value) {
	switch (xs) {
	case nil: return xs;
	case cons(x, xs0): return (x == value ? xs : removeFromList(xs0, value));
	}
}
@*/

interface Set {
	//@predicate set(list<Object> elems);
	
	boolean isEmpty();
		//@ requires set(?elems);
		//@ ensures set(elems) &*& result == (length(elems) == 0);

	int size();
		//@ requires set(?elems);
		//@ ensures set(elems) &*& result == length(elems);
	
	void clear();
		//@ requires set(?elems);
		//@ ensures set(elems) &*& length(elems) == 0;
	
	boolean contains(Object e);
		//@ requires set(?elems);
		//@ ensures set(elems);
	
	void add(Object e);
		//@ requires set(?elems) &*& containsInList(elems,e) == false;
		//@ ensures set(elems) &*& containsInList(elems,e) == true &*& set(cons(e, elems));
	
	void remove(Object e);
		//@ requires set(?elems) &*& containsInList(elems,e) == true;
		//@ ensures set(elems) &*& containsInList(elems,e) == false &*& set(cons(e, elems));
}

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

/*@
predicate listOf(Node node; list<Object> elems) =
  node == null ?
    elems == nil
  :
    node.value |-> ?v &*&
    node.next |-> ?n &*&
    listOf(n, ?nelems) &*&
    elems == cons(v, nelems);
@*/

class ObjectSet {//implements Set{
	/*@
	predicate set(list<Object> elems) =
	head |-> ?h &*& listOf(h, elems) &*&
	size |-> length(elems);
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
	//@ ensures set(elems);
	{
		//@open set(elems);
		return contains(e, head);
		//@close set(elems);
	}

	private static boolean contains (Object e, Node current)
	//@ requires current.value |-> ?v &*& current.next |-> ?n;
	//@ ensures current.value |-> v &*& current.next |-> n;
	{
		if (current == null) {
			return false;
		} else {
			if (current.value == e) {
				return true;
			} else {
				return contains(e, current.next);
			}
		}		
		//return current != null && current.value == e ? true : get (index - 1, current.next);
	}

	public void add(Object e)
	{
		if(isEmpty()) {
			head = new Node(e, null);
			size++;
		} else {
			addAux(e,head);
		}		
	}

	private void addAux (Object e, Node current)
	{
		if(current.value == e) {
			return;
		} else {
			if (current.next == null) {
				current.next = new Node(e, null);
				size++;
			} else {
				addAux(e, current.next);
			}
		}
	}

	public void remove(Object e)
	{
		if(isEmpty()) {
			return;
		} else if(head.value == e) {
			head = head.next;
			size--;	
		} else {
			removeAux(e,head,head.next);
		}
	}

	private void removeAux(Object e, Node previous, Node current)
	{
		if (current == null) {
			return;
		} else {
			if (current.value == e) {
				previous.next = current.next;
				size--;
			}
		}		
	}


	/*public static void main(String[] args)
	//@ requires System_out(?o) &*& o != null;
	//@ ensures true;
	{
		ObjectSet set = new ObjectSet();
		System.out.println(set.size());
		set.clear();
		System.out.println(set.size());
		Integer a = new Integer(1);
		Integer aa = new Integer(1);
		Integer b = new Integer(2);
		set.add(a);
		set.add(a);
		set.add(b);
		System.out.println("size " + set.size());
		System.out.println(set.contains(a));
		System.out.println(set.contains(b));
		set.remove(b);
		System.out.println(set.contains(b));
		System.out.println("size " + set.size());
		System.out.println("clear");
		set.clear();
		System.out.println("size " + set.size());
		System.out.println(set.contains(a));
		System.out.println(set.contains(b));
	}*/




}