package com.example.miletracker;

import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.google.firebase.FirebaseApp;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class MainActivity extends AppCompatActivity {

    private TextView txtvDBStatus;
    private Button btnTest;
    FirebaseDatabase MiLogDB;
    FirebaseApp fireApp;
    DatabaseReference DBRef;
    long status;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        fireApp.initializeApp(this);
        MiLogDB = FirebaseDatabase.getInstance();
        DBRef = MiLogDB.getReference("CheckStatus");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        txtvDBStatus = findViewById(R.id.txtvSplashDBStatus);
        btnTest = findViewById(R.id.btnTestDB);

    }

    public void isOnline(View v){
        DBRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                status = (long) dataSnapshot.child("Online").getValue();
                check();
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {
                throw databaseError.toException();
            }
        });

    }

    void check(){
        if(status == 1){
            txtvDBStatus.setText("Connected to Firebase DB!");
        }
        else
            txtvDBStatus.setText("Not connected to Firebase DB!");
    }
}
