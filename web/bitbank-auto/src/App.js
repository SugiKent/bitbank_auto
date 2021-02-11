import React, { useEffect, useMemo, useState } from "react";
import moment from "moment";

import { fetchHistory } from "./firebaseAPI";

const App = () => {
  const [histories, setHistories] = useState(null);

  useEffect(() => {
    const fetch = async () => {
      const result = await fetchHistory();
      setHistories(result);
    };

    fetch();
  }, []);

  const pl = useMemo(() => {
    let pl = 0;
    if (!histories) {
      return pl;
    }

    histories.forEach((h) => {
      if (h.side === "buy") {
        pl = pl - h.price * h.amount;
      } else {
        pl = pl + h.price * h.amount;
      }
    });

    return pl;
  }, [histories]);

  return (
    <>
      <p>損益 {pl}円</p>
      <table>
        <thead>
          <tr>
            <th>Datetime</th>
            <th>Side</th>
            <th>Price</th>
            <th>Amount</th>
          </tr>
        </thead>
        {histories && (
          <tbody>
            {histories.map((history, i) => {
              return (
                <tr key={i}>
                  <td>
                    {moment(history.created_at.toDate()).format("M/D hh:mm:ss")}
                  </td>
                  <td>{history.side}</td>
                  <td>{history.price}</td>
                  <td>{history.amount}</td>
                </tr>
              );
            })}
          </tbody>
        )}
      </table>
    </>
  );
};

export default App;
