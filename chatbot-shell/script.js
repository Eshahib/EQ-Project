/*
 * AI Friend — front-end-only chatbot shell for HPU students.
 * No AI service, survey service, or backend is connected yet.
 * The integration notes below show where the team can attach those features.
 */
(() => {
  'use strict';

  // -------- DOM elements --------
  const chatForm = document.getElementById('chatForm');
  const messageInput = document.getElementById('messageInput');
  const sendBtn = document.getElementById('sendBtn');
  const micBtn = document.getElementById('micBtn');
  const speechHint = document.getElementById('speechHint');
  const messages = document.getElementById('messages');
  const thread = document.getElementById('messageThread');
  const endChatBtn = document.getElementById('endChatBtn');
  // Loading indicator displayed while waiting for AI Friend.
  const aiLoading = document.getElementById('aiLoading');
  // Emotion picker controls.
  const emotionBtn = document.getElementById('emotionBtn');
  const emotionMenu = document.getElementById('emotionMenu');

  // -------- Session state --------
  // The survey page will eventually provide the session ID and survey context.
  const session = {
    id: (window.crypto && crypto.randomUUID) ? crypto.randomUUID() : `session-${Date.now()}`,
    createdAt: new Date().toISOString(),
    messages: [],
    ended: false
  };
  // Saved Experiences page can later read or migrate entries from this key.
  const STORAGE_KEY = 'hpu-ai-friend-saved-experiences';
  // Tracks whether AI Friend is currently generating a response.
  let waitingForResponse = false;

  // -------- Message display --------
  // Use textContent to keep user-supplied text from being interpreted as HTML.
  function addMessage(role, text) {
    const message = { role, text, timestamp: new Date().toISOString() };
    session.messages.push(message);

    const item = document.createElement('article');
    item.className = `message ${role}`;
    if (role === 'assistant') {
      // Show the same HPU avatar as the page header beside assistant messages.
      const avatar = document.createElement('span');
      avatar.className = 'assistant-avatar';
      const image = document.createElement('img');
      image.src = 'assets/hpu-logo.png';
      image.alt = 'HPU';
      avatar.appendChild(image);
      item.appendChild(avatar);
    }
    const bubble = document.createElement('div');
    bubble.className = 'message-body';
    bubble.textContent = text;
    item.appendChild(bubble);
    thread.appendChild(item);
    messages.scrollTop = messages.scrollHeight;
  }

  // Placeholder first response: replace with a real AI response based on the survey.
  // This does NOT analyze survey answers or pretend to generate personalized advice.
  addMessage('assistant', "Place holder message where we will put the response to the survey part");

  // -------- Text entry --------
  function updateComposer() {
      // Disable input controls while AI Friend is responding
      // or after the conversation has ended.
      messageInput.disabled = session.ended || waitingForResponse;
      micBtn.disabled = session.ended || waitingForResponse;

      // Only allow sending when the chatbot is ready
      // and the user has entered a message.
      sendBtn.disabled = session.ended ||
                        waitingForResponse ||
                        !messageInput.value.trim();

      // Automatically resize the message input.
      messageInput.style.height = 'auto';
      messageInput.style.height = `${Math.min(messageInput.scrollHeight, 160)}px`;

      // Disable emotion selection while waiting for the AI.
      emotionBtn.disabled = session.ended || waitingForResponse;

      // Close the menu whenever emotion selection is disabled.
      if (emotionBtn.disabled) setEmotionMenuOpen(false);
  }

  
  /* ============================================================
    EMOTION PICKER FUNCTIONALITY
    ============================================================ */

  /**
   * Opens or closes the emotion selection menu.
   */
  function setEmotionMenuOpen(open) {
      emotionMenu.hidden = !open;
      emotionBtn.setAttribute('aria-expanded', String(open));
  }

  // Open or close the popup when the emoji button is clicked.
  emotionBtn.addEventListener('click', () => {
      if (session.ended || waitingForResponse) return;

      setEmotionMenuOpen(emotionMenu.hidden);
  });

  // Insert the selected emotion into the message input.
  emotionMenu.querySelectorAll('.emotion-option').forEach(option => {
      option.addEventListener('click', () => {
          if (session.ended || waitingForResponse) return;

          const emoji = option.dataset.emotion;
          const label = option.dataset.label;

          // Insert both the emoji and its meaning into the message.
          const emotionText = `${emoji} ${label}`;
          // Insert the selected emotion, followed by a space for easy typing.
          messageInput.value +=
              (messageInput.value && !/\s$/.test(messageInput.value) ? ' ' : '') +
              emotionText + ' ';

          // Close the picker and update the Send button.
          setEmotionMenuOpen(false);
          updateComposer();
          messageInput.focus();
      });
  });

  // Close the popup when clicking elsewhere on the page.
  document.addEventListener('click', event => {
      if (!event.target.closest('.emotion-picker')) {
          setEmotionMenuOpen(false);
      }
  });

  // Allow Escape to close the popup.
  document.addEventListener('keydown', event => {
      if (event.key === 'Escape' && !emotionMenu.hidden) {
          setEmotionMenuOpen(false);
          emotionBtn.focus();
      }
  });


  /**
   * Shows or hides the AI response loading indicator.
   *
   * @param {boolean} loading - True while waiting for the AI.
   */
  function setAILoading(loading) {

      // Show the indicator when loading, hide it otherwise.
      aiLoading.hidden = !loading;

      // Scroll down so the loading indicator is visible.
      if (loading) {
          messages.scrollTop = messages.scrollHeight;
      }
  }

  function submitMessage() {
      // Do not allow messages if the chat has ended
      // or the AI is currently responding.
      if (session.ended || waitingForResponse) return;

      const text = messageInput.value.trim();
      if (!text) return;

      // Display the user's message.
      addMessage('user', text);

      // Clear the input field.
      messageInput.value = '';

      // Lock the user's input while waiting for a response.
      waitingForResponse = true;
      updateComposer();

      // Display the animated loading indicator.
      setAILoading(true);

      // Begin generating the AI response.
      generateAIResponse();



      // FUTURE AI INTEGRATION:
      // Replace the placeholder with the real AI response.
  }

  // Submit on Send or Enter; Shift+Enter inserts a newline instead.
  chatForm.addEventListener('submit', event => { event.preventDefault(); submitMessage(); });
  messageInput.addEventListener('input', updateComposer);
  messageInput.addEventListener('keydown', event => {
    if (event.key === 'Enter' && !event.shiftKey && !event.isComposing) {
      event.preventDefault();
      submitMessage();
    }
  });

/**
 * Generates a temporary AI Friend response.
 *
 * Shows a loading animation while waiting and removes it
 * once the response is displayed.
 */
function generateAIResponse() {

    // Temporary response until the AI backend is connected.
    const response = "This is a placeholder AI response. " +
        "Eventually, I will respond to what you tell me!";

    // Simulate an AI response delay.
    setTimeout(() => {

        // Don't display a response after the chat has ended.
        if (session.ended) {
            setAILoading(false);
            return;
        }

        // Hide the loading indicator.
        setAILoading(false);

        // Display the chatbot's response.
        addMessage("assistant", response);

        // Allow the user to send another message.
        waitingForResponse = false;
        updateComposer();

        // Return focus to the message input.
        messageInput.focus();

    }, 1000);
}

  // -------- End chat and Saved Experiences handoff --------
  endChatBtn.addEventListener('click', () => {
    if (session.ended) return;
    // Ask first so an accidental click doesn't terminate the session.
    if (!window.confirm('End this conversation and save it on this device?')) return;

    // Local-only prototype storage. A real student-support app should define
    // explicit consent, retention, privacy and secure server storage policies.
    const completedSession = { ...session, ended: true, endedAt: new Date().toISOString() };
    try {
      const previous = JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]');
      const saved = Array.isArray(previous) ? previous : [];
      saved.push(completedSession);
      localStorage.setItem(STORAGE_KEY, JSON.stringify(saved));
    } catch (error) {
      // Do not claim anything was saved when browser storage is unavailable.
      window.alert('This browser could not save the conversation. The chat will remain open so you can try again.');
      return;
    }

    session.ended = true;
    // Remove the loading indicator if the chat ends mid-response.
    setAILoading(false);
    // Lock chat controls after the record is stored.
    messageInput.disabled = true;
    micBtn.disabled = true;
    endChatBtn.disabled = true;
    updateComposer();
    if (typeof stopSpeech === 'function') stopSpeech();

    const notice = document.createElement('section');
    notice.className = 'ended-notice';
    const heading = document.createElement('h2');
    heading.textContent = 'Conversation ended';
    const details = document.createElement('p');
    details.textContent = 'This conversation is saved in this browser. The Saved Experiences page will be connected later.';
    notice.append(heading, details);
    thread.appendChild(notice);
    messages.scrollTop = messages.scrollHeight;
    // FUTURE STORAGE INTEGRATION: replace localStorage with an authenticated API.
  });

  // -------- Browser speech-to-text --------
  // This may rely on your browser's speech provider. Browser support varies.
  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  let stopSpeech = () => {};
  if (!SpeechRecognition) {
    micBtn.addEventListener('click', () => {
      speechHint.textContent = 'Voice typing is not supported in this browser. Try Chrome or Edge.';
    });
  } else {
    const recognition = new SpeechRecognition();
    recognition.lang = 'en-US';
    recognition.continuous = false;
    recognition.interimResults = true;
    let listening = false;
    let originalText = '';
    const defaultHint = speechHint.textContent;

    // Keep the microphone styling and accessible state synchronized.
    function setListening(active) {
      listening = active;
      micBtn.classList.toggle('listening', active);
      micBtn.setAttribute('aria-pressed', String(active));
      micBtn.setAttribute('aria-label', active ? 'Stop voice typing' : 'Start voice typing');
      speechHint.textContent = active ? 'Listening… click the microphone to stop.' : defaultHint;
    }
    stopSpeech = () => { if (listening) recognition.stop(); };

    micBtn.addEventListener('click', () => {
      if (session.ended || waitingForResponse) return;
      if (listening) { recognition.stop(); return; }
      originalText = messageInput.value.trimEnd();
      try { recognition.start(); }
      catch (error) { speechHint.textContent = 'Could not start voice typing. Try again.'; }
    });
    recognition.addEventListener('start', () => setListening(true));
    recognition.addEventListener('result', event => {
      if (session.ended || waitingForResponse) return;
      let transcript = '';
      for (let i = 0; i < event.results.length; i++) transcript += event.results[i][0].transcript;
      messageInput.value = originalText + (originalText && transcript ? ' ' : '') + transcript;
      updateComposer();
    });
    recognition.addEventListener('end', () => setListening(false));
    recognition.addEventListener('error', event => {
      setListening(false);
      speechHint.textContent = event.error === 'not-allowed'
        ? 'Microphone access was denied. Allow microphone access in your browser.'
        : 'Voice typing was interrupted. You can try again.';
    });
  }

  // Set the initial disabled/enabled state of the Send button.
  updateComposer();
})();
