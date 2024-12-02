import React, { useEffect, useState } from 'react';
import UploadForm from './UploadForm';
import DataForm from './DataForm';
import DataDisplay from './DataDisplay';
import './App.css';

const App = () => {
  const [data, setData] = useState([]);
  const [messages, setMessages] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      const response = await fetch('/all-data');
      const result = await response.json();
      setData(result);
    };

    fetchData();

    const ws = new WebSocket(`ws://${window.location.host}`);
    ws.onmessage = async (event) => {
      const message = JSON.parse(event.data);
      setMessages((prevMessages) => [...prevMessages, message]);

      // Fetch all data from DynamoDB
      const response = await fetch('/all-data');
      const result = await response.json();
      setData(result);
    };

    return () => {
      ws.close();
    };
  }, []);

  return (
    <div className="App">
      <h1>Address Info</h1>
      <UploadForm />
      <DataForm setData={setData} />
      <h2>Form Data</h2>
      <DataDisplay data={data} />
      <ul>
        {messages.map((message, index) => (
          <li key={index}>{JSON.stringify(message, null, 2)}</li>
        ))}
      </ul>
    </div>
  );
};

export default App;