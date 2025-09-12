(() => {
  const State = Object.freeze({
    IDLE: 'IDLE',
    RUNNING: 'RUNNING',
    PAUSED: 'PAUSED',
    FINISHED: 'FINISHED',
  });

  const $display = document.getElementById('display');
  const $btn3 = document.getElementById('btn3');
  const $btn5 = document.getElementById('btn5');
  const $btnToggle = document.getElementById('btnToggle');

  let state = State.IDLE;
  let remainingSec = 0;
  let timerId = null; // setInterval handle
  let targetEpochMs = null; // number | null

  const pad2 = (n) => String(n).padStart(2, '0');
  const format = (sec) => `${pad2(Math.floor(sec / 60))}.${pad2(sec % 60)}`;

  function render() {
    $display.textContent = format(remainingSec);
    $btnToggle.textContent = state === State.RUNNING ? 'ストップ' : 'スタート';
  }

  function clearTick() {
    if (timerId != null) {
      clearInterval(timerId);
      timerId = null;
    }
  }

  function resetTo(sec) {
    clearTick();
    remainingSec = sec;
    state = State.IDLE;
    targetEpochMs = null;
    render();
  }

  function tick() {
    const now = Date.now();
    const deltaMs = Math.max(0, (targetEpochMs ?? now) - now);
    const nextRemaining = Math.max(0, Math.ceil(deltaMs / 1000));

    if (nextRemaining !== remainingSec) {
      remainingSec = nextRemaining;
      render();
    }

    if (nextRemaining === 0) {
      clearTick();
      state = State.FINISHED;
      alert('時間になりました');
      render();
    }
  }

  function startTimer() {
    clearTick();
    state = State.RUNNING;
    targetEpochMs = Date.now() + remainingSec * 1000;
    // Use sub-second tick with real-time correction; render only on second changes
    timerId = setInterval(tick, 200);
    render();
  }

  // Event handlers
  $btn3.addEventListener('click', () => resetTo(180));
  $btn5.addEventListener('click', () => resetTo(300));

  $btnToggle.addEventListener('click', () => {
    if (state === State.RUNNING) {
      clearTick();
      state = State.PAUSED;
      render();
      return;
    }
    if (state === State.PAUSED && remainingSec > 0) {
      startTimer();
      return;
    }
    if (state === State.IDLE && remainingSec > 0) {
      startTimer();
      return;
    }
    // FINISHED or remainingSec == 0 -> do nothing
  });

  // Initial paint
  render();
})();

