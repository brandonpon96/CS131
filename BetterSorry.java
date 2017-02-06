import java.util.concurrent.atomic.AtomicInteger;

class BetterSorry implements State {
	private byte[] value;
	private byte maxval;
	
	BetterSorry(byte[] v) {
		value = v;
		maxval = 127;
	}

	BetterSorry(byte[] v, byte m){
		value = v;
		maxval = m;
	}

	public int size() { return value.length; }

	public byte[] current() { return value; }

	public boolean swap(int i, int j){

		AtomicInteger a = new AtomicInteger(value[i]);
		AtomicInteger b = new AtomicInteger(value[j]);

		if (a.get() <= 0 || b.get() >= maxval){
			return false;
		}
		value[i] = (byte)a.getAndDecrement();
		value[j] = (byte)b.getAndIncrement();
		return true;
	}

}