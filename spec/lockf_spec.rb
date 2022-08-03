require_relative "setup"

RSpec.describe "Lockf#lockf" do
  include Timeout

  let(:file) { Tempfile.new("lockf-test_file").tap(&:unlink) }
  let(:lock) { Lock::File.new(file, 0) }

  after do
    lock.file.close
  end

  exit_on = ->(ex, code: 42, &b) do
    b.call
  rescue
    exit(code)
  end

  describe "F_LOCK" do
    subject(:obtain_lock) { lock.obtain }
    before { obtain_lock }
    after { lock.release }

    context "when a lock is acquired" do
      it { is_expected.to be_zero }
    end

    context "when a second lock is attempted by a fork" do
      subject(:pid) { fork { lock.obtain } }
      after { Process.kill("SIGKILL", pid) }

      it "blocks the fork" do
        expect {
          timeout(0.5) { Process.wait(pid) }
        }.to raise_error(Timeout::Error)
      end
    end
  end

  describe "F_TLOCK" do
    subject(:obtain_lock) { lock.obtain_nonblock }
    before { obtain_lock }
    after { lock.release }

    context "when a lock is acquired" do
      it { is_expected.to be_zero }
    end

    context "when a second lock is attempted by a fork" do
      subject { Process.wait2(pid).last.exitstatus }
      let(:pid) { fork { exit_on.call(Errno::EAGAIN) { lock.obtain_nonblock } } }
      it { is_expected.to eq(42) }
    end
  end

  describe "F_TEST" do
    let(:obtain_lock) { lock.obtain }
    before { obtain_lock }
    after { lock.release }

    context "when a lock wouldn't block" do
      subject { lock.locked? }
      it { is_expected.to be(false) }
    end

    context "when a second lock would block" do
      subject { Process.wait2(pid).last.exitstatus }
      let(:pid) { fork { lock.locked? and exit(42) } }
      it { is_expected.to eq(42) }
    end
  end

  describe "F_ULOCK" do
    let(:obtain_lock) { lock.obtain }
    before { obtain_lock }

    context "when a lock is acquired, and then removed" do
      subject { Process.wait2(pid).last.exitstatus }
      let(:unlock) { lock.release }
      let(:pid) { fork { lock.locked?.then { exit(42) } } }
      before { lock.then { unlock } }
      it { is_expected.to eq(42) }
    end
  end
end
