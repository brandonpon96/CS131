import java.util.concurrent.locks.ReentrantLock;

class BetterSafe implements State {
	private byte[] value;
	private byte maxval;

/* A reentrant mutual exclusion Lock with the same basic behavior and
semantics as the implicit monitor lock accessed using synchronized
methods and statements, but with extended capabilities. */
	private ReentrantLock lock;
	
	BetterSafe(byte[] v) {
		value = v;
		maxval = 127;
		lock = new ReentrantLock();
	}

	BetterSafe(byte[] v, byte m){
		value = v;
		maxval = m;
		lock = new ReentrantLock();
	}

	public int size() { return value.length; }

	public byte[] current() { return value; }

	public boolean swap(int i, int j){
		lock.lock();
		if (value[i] <= 0 || value[j] >= maxval){
			lock.unlock();
			return false;
		}
		value[i]--;
		value[j]++;
		lock.unlock();
		return true;
	}

}